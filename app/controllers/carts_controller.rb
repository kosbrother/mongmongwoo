require "uri"

class CartsController < ApplicationController
  layout 'cart'

  skip_before_action :verify_authenticity_token, only: [:info]
  before_action  :load_categories
  before_action :calculate_cart_price, only: [:checkout, :confirm]

  include DeviceHelper

  def checkout
    @step = Cart::STEP[:checkout]
    @items = current_cart.cart_items.includes({item: :specs}, :item_spec)
    if @items.empty?
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
    cookies[:name] = params[:name]
    cookies[:email] = params[:email]
    cookies[:phone] = params[:phone]

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

    cookies[:name] = params[:ship_name]
    cookies[:email] = params[:ship_email]
    cookies[:phone] = params[:ship_phone]
    @info = {ship_name: cookies[:name],
             ship_phone: cookies[:phone],
             ship_email: cookies[:email]}
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

    @items = current_cart.cart_items.includes(:item, :item_spec)
    set_meta_tags title: "確認訂單", noindex: true
  end

  def submit
    items = current_cart.cart_items.includes(:item, :item_spec)
    @order,errors = create_order(items, params[:info])
    if errors.present?
      @unable_to_buy_lists = errors.select{|error| error.key?(:unable_to_buy)}.map{|list| list[:unable_to_buy][0]}
      @updated_items = destroy_and_return_items(@unable_to_buy_lists)
      add_to_wish_lists(@unable_to_buy_lists) if current_user
      render 'error_infos'
    else
      ShoppingPointManager.spend_shopping_points(@order, current_cart.shopping_point_amount)
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
      items_price = current_cart.calculate_items_price
      shopping_point_amount = ShoppingPointManager.new(current_user).calculate_available_shopping_point(items_price)
      current_cart.update(shopping_point_amount: shopping_point_amount)
    else
      current_cart.update(shopping_point_amount: 0)
    end
    calculate_cart_price
  end

  private

  def calculate_cart_price
    @items_price = current_cart.calculate_items_price
    @reduced_items_price = current_cart.calculate_reduced_items_price
    @shopping_point_amount = current_cart.shopping_point_amount
    @ship_fee = current_cart.calculate_ship_fee
    @total = current_cart.calculate_total
  end

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  def create_order(cart_items, cart_info)
    errors = []
    order = nil
    ActiveRecord::Base.transaction do
      order = Order.new
      order.uid = current_cart.user.uid
      order.user_id = current_cart.user_id
      order.items_price = current_cart.calculate_items_price
      order.ship_fee = current_cart.calculate_ship_fee
      order.ship_type = current_cart.ship_type
      order.total = current_cart.calculate_total
      order.save

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
      info.save

      cart_items.each do |cart_item|
        item = OrderItem.new
        item.order_id = order.id
        item.item_name = cart_item.item.name
        item.source_item_id = cart_item.item_id
        item.item_spec_id = cart_item.item_spec_id
        item.item_style = cart_item.item_spec.style
        item.item_quantity = cart_item.item_quantity
        item.item_price = cart_item.item.special_price ||  cart_item.item.price
        errors << item.errors.messages unless item.save
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
      updated_items << {id: cart_item.id, item_quantity: cart_item.item_quantity}
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
end