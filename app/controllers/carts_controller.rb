require "uri"

class CartsController < ApplicationController
  layout 'cart'
  skip_before_action :verify_authenticity_token, only: :info
  before_action  :load_categories

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

    url = generate_url(ENV['ALL_PAY_URL'],
                       MerchantID: ENV['MERCHANT_ID'],
                       MerchantTradeNo: '1111',
                       LogisticsType: 'CVS',
                       LogisticsSubType: 'UNIMART',
                       IsCollection: 'Y',
                       ServerReplyURL: store_reply_url)

    render json: {url: url}
  end

  def confirm
    @step = Cart::STEP[:confirm]
    @info = {ship_name: params[:ship_name],
             ship_phone: params[:ship_phone],
             ship_email: params[:ship_email]}
    @store = Store.find(params[:store_id])
    @items = current_cart.cart_items.includes(:item, :item_spec)
    @total = current_cart.calculate_items_price
    set_meta_tags title: "確認訂單", noindex: true
  end

  def submit
    items = current_cart.cart_items.includes(:item, :item_spec)
    store = Store.find(params[:store])
    order,errors = create_order(items, params[:info], store)
    if errors.present?
      # need handle errors here
      redirect_to checkout_path
    else
      session[:cart_id] = nil
      OrderMailer.delay.notify_order_placed(order)
      redirect_to success_path
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
end