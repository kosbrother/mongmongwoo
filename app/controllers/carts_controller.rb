require "uri"

class CartsController < ApplicationController
  include DeviceHelper

  layout 'cart'

  skip_before_action :verify_authenticity_token, only: [:info]
  before_action  :load_categories_and_campaigns
  before_action :calculate_cart_price, only: [:checkout, :confirm]
  before_action :save_info_to_cookies, only: [:select_store, :confirm]

  def checkout
    @step = Cart::STEP[:checkout]
    if @cart_items.empty?
      flash[:notice] = " 您的購物車目前是空的，快點加入您喜愛的商品吧！"
      redirect_to root_path
    end
    @user_own_shopping_point = ShoppingPointManager.new(current_user).calculate_available_shopping_point(@items_price) if current_user
    set_meta_tags title: "確認訂單", noindex: true
  end

  def update_ship_type
    current_cart.update_column(:ship_type, params[:ship_type])
    render nothing: true
  end

  def get_towns
    @towns = Town.where(county_id: params[:county_id])
  end

  def info
    @items = current_cart.cart_items.includes(:item, :item_spec)
    @step = Cart::STEP[:info]
    if current_cart.ship_type == "store_delivery" && params['CVSStoreID']
      @store = Store.find_by(store_code: params['CVSStoreID'])
      cookies[:store_id] = @store.id
    elsif current_cart.ship_type == "store_delivery" && cookies[:store_id]
      @store = Store.find_by(id: cookies[:store_id])
    elsif Cart::HOME_DELIVERY_TYPES.include?(current_cart.ship_type)
      @counties = County.where(store_type: 4)
      @county = @counties.find_by(id: cookies[:county_id]) || @counties.first
      @towns = @county.towns
    end
    set_meta_tags title: "訂購資料", noindex: true
  end

  def select_store
    url_query = {MerchantID: ENV['MERCHANT_ID'],
                 MerchantTradeNo: '1111',
                 LogisticsType: 'CVS',
                 LogisticsSubType: 'UNIMART',
                 IsCollection: 'Y',
                 ServerReplyURL: store_reply_url}
    url_query = url_query.merge(Device: 1) if mobile?
    url = generate_url('http://logistics.allpay.com.tw/Express/map', url_query)

    render json: {url: url}
  end

  def confirm
    @step = Cart::STEP[:confirm]

    @info = {ship_name: cookies[:ship_name],
             ship_phone: cookies[:ship_phone],
             ship_email: cookies[:ship_email]}
    if Cart::HOME_DELIVERY_TYPES.include?(current_cart.ship_type)
      cookies[:county_id] = params[:county_id]
      cookies[:town_id] = params[:town_id]
      cookies[:road] = params[:road]
      @ship_address = generate_address(cookies[:county_id], cookies[:town_id], cookies[:road])
      @info = @info.merge(ship_address: @ship_address)
    elsif current_cart.ship_type == "store_delivery"
      @store = Store.find(cookies[:store_id])
      @info = @info.merge(store_id: @store.id)
    end

    set_meta_tags title: "確認訂單", noindex: true
  end

  def submit
    @order,errors = create_order(params[:info])
    if errors.present?
      @unable_to_buy_lists = errors.select{|error| error.key?(:unable_to_buy)}.map{|list| list[:unable_to_buy][0]}
      @updated_items = destroy_and_return_items(@unable_to_buy_lists)
      add_to_wish_lists(@unable_to_buy_lists) if current_user
      calculate_cart_price
      render 'error_infos'
    else
      session[:cart_id] = nil
      OrderMailer.delay.notify_order_placed(@order) if (@order.store_delivery? || @order.home_delivery?)
    end
  end

  def success
    @order = Order.find(params[:order_id])
    @step = Cart::STEP[:finish]
  end

  def toggle_shopping_point
    if current_cart.shopping_point_amount == 0
      cart = PriceManagerForCart.new(current_cart)
      items_price = cart.items_price
      shopping_point_amount = ShoppingPointManager.new(current_user).calculate_available_shopping_point(items_price)
      current_cart.update(shopping_point_amount: shopping_point_amount)
    else
      current_cart.update(shopping_point_amount: 0)
    end
    calculate_cart_price
    render "cart_items/update_cart_price"
  end

  private


  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  def create_order(cart_info)
    errors = []
    order = nil
    user = current_cart.user
    cart = PriceManagerForCart.new(current_cart)
    ActiveRecord::Base.transaction do
      order = Order.new
      order.uid = user.uid
      order.user_id = user.id
      order.items_price = cart.items_price
      order.ship_fee = cart.ship_fee
      order.ship_type = current_cart.ship_type
      order.total = cart.total
      errors << order.errors.messages unless order.save
      DiscountRecordCreator.create_by_type_if_applicable(order)
      ShoppingPointManager.new(user).create_shopping_point_if_applicable(order, cart.shopping_point_amount)
      ShoppingPointManager.new(user).spend_shopping_points(order, cart.shopping_point_amount)

      info = OrderInfo.new
      info.order_id = order.id
      info.ship_name = cart_info[:ship_name]
      info.ship_phone = cart_info[:ship_phone]
      info.ship_email = cart_info[:ship_email]
      if Cart::HOME_DELIVERY_TYPES.include?(current_cart.ship_type)
        info.ship_address = cart_info[:ship_address]
      elsif current_cart.ship_type == "store_delivery"
        store = Store.find(cart_info[:store_id])
        info.ship_store_code = store.store_code
        info.ship_store_id = store.id
        info.ship_store_name = store.name
      end
      errors << info.errors.messages unless info.save

      cart.cart_items.each do |cart_item|
        item = OrderItem.new
        item.order_id = order.id
        item.item_name = cart_item.item.name
        item.source_item_id = cart_item.item.id
        item.item_spec_id = cart_item.item_spec.id
        item.item_style = cart_item.item_spec.style
        item.item_quantity = cart_item.item_quantity
        item.item_price = cart_item.discounted_price
        errors << item.errors.messages unless item.save
        DiscountRecordCreator.create_by_type_if_applicable(item)
      end
      raise ActiveRecord::Rollback if errors.present?
    end
    [order,errors]
  end

  def destroy_and_return_items(unable_to_buy_lists)
    updated_items = []
    unable_to_buy_lists.each do |list|
      cart_item = current_cart.cart_items.find_by(item_spec_id: list[:spec].id)
      if list[:spec].status == 'off_shelf'
        cart_item.update(item_quantity: 0)
      else
        cart_item.update(item_quantity: list[:spec].stock_amount)
      end
      p = PriceManagerForCartItem.new(cart_item)
      updated_items << p
      cart_item.destroy if cart_item.item_quantity == 0
    end
    updated_items
  end

  def add_to_wish_lists(unable_to_buy_lists)
    unable_to_buy_lists.each do |list|
      current_user.wish_lists.find_or_create_by(item_id: list["id"] ,item_spec_id: list[:spec].id)
    end
  end

  def generate_address(county_id, town_id, road)
    county = County.find(county_id)
    town = Town.find(town_id)
    county.name + town.name + road
  end

  def save_info_to_cookies
    cookies[:ship_name] = params[:ship_name]
    cookies[:ship_email] = params[:ship_email]
    cookies[:ship_phone] = params[:ship_phone]
  end
end