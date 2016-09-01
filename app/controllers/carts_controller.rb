require "uri"

class CartsController < ApplicationController
  layout 'cart'
  skip_before_action :verify_authenticity_token, only: :info
  before_action  :load_categories
  include DeviceHelper

  def checkout
    @step = Cart::STEP[:checkout]
    @items = current_cart.cart_items.includes({item: :specs}, :item_spec)
    if @items.empty?
      flash[:notice] = " 您的購物車目前是空的，快點加入您喜愛的商品吧！"
      redirect_to root_path
    end
    @total = current_cart.calculate_items_price
    set_meta_tags title: "確認訂單", noindex: true
  end

  def info
    @step = Cart::STEP[:info]
    if params['CVSStoreID']
      @store = Store.find_by(store_code: params['CVSStoreID'])
      cookies[:store_id] = @store.id
    elsif cookies[:store_id]
      @store = Store.find_by(id: cookies[:store_id])
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
    @info = {ship_name: cookies[:name],
             ship_phone: cookies[:phone],
             ship_email: cookies[:email]}
    @store = Store.find(cookies[:store_id])
    @items = current_cart.cart_items.includes(:item, :item_spec)
    @total = current_cart.calculate_items_price
    set_meta_tags title: "確認訂單", noindex: true
  end

  def submit
    items = current_cart.cart_items.includes(:item, :item_spec)
    store = Store.find(params[:store])
    order,errors = create_order(items, params[:info], store)
    if errors.present?
      @unable_to_buy_lists = errors.select{|error| error.key?(:unable_to_buy)}.map{|list| list[:unable_to_buy][0]}
      @updated_items = destroy_and_return_items(@unable_to_buy_lists)
      add_to_wish_lists(@unable_to_buy_lists) if current_user
      render 'error_infos'
    else
      session[:cart_id] = nil
      OrderMailer.delay.notify_order_placed(order)
      render :js => "window.location = '#{success_path}'"
    end
  end

  private

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  def create_order(cart_items, cart_info, store)
    errors = []
    order = nil
    ActiveRecord::Base.transaction do
      order = Order.new
      order.uid = current_cart.user.uid
      order.user_id = current_cart.user_id
      order.items_price = current_cart.calculate_items_price
      order.ship_fee = current_cart.calculate_ship_fee
      order.total = current_cart.calculate_total
      order.save

      info = OrderInfo.new
      info.order_id = order.id
      info.ship_name = cart_info[:ship_name]
      info.ship_phone = cart_info[:ship_phone]
      info.ship_store_code = store.store_code
      info.ship_store_id = store.id
      info.ship_store_name = store.name
      info.ship_email = cart_info[:ship_email]
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
      cart_item.update(item_quantity: list[:spec].stock_amount)
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
end