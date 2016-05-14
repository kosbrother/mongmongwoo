require "uri"
require "net/http"

class CartsController < ApplicationController
  layout 'cart'
  skip_before_action :verify_authenticity_token, only: :store_reply
  skip_before_action :load_popular_items

  def checkout
    @step = 1
    @cart =  Cart.find(session[:cart_id])
    @items = @cart.cart_items.includes({item: :specs}, :item_spec)
    @total = items_total(@items)
  end

  def info
    @step = 2
    if params['store']
      @store = Store.find_by(store_code: params['store'])
    end
  end

  def select_store
    url = generate_url(ENV['ALL_PAY_URL'],
                       MerchantID: ENV['MerchantID'],
                       MerchantTradeNo: ENV['MerchantTradeNo'],
                       LogisticsType: 'CVS',
                       LogisticsSubType: 'UNIMART',
                       IsCollection: 'Y',
                       ServerReplyURL: "#{ENV['WEB_HOST']}/store_reply")
    redirect_to  url
  end

  def store_reply
    redirect_to cart_info_path(store:  params['CVSStoreID'])
  end

  def create_info
    @info = {ship_name: params[:ship_name],
             ship_phone: params[:ship_phone],
             ship_email: params[:ship_email]}
    redirect_to confirm_cart_path(info: @info, store: params[:store_id])
  end

  def confirm
    @step = 3
    @cart =  Cart.find(session[:cart_id])
    @items = @cart.cart_items.includes(:item, :item_spec)
    @store = Store.find(params[:store])
    @info = params[:info]
    @total = items_total(@items)
  end

  def submit
    cart =  Cart.includes({cart_items: [:item, :item_spec]}).find(session[:cart_id])
    store = Store.find(params[:store])
    create_order(cart, params[:info], store)
    session[:cart_id] = nil

    redirect_to success_path
  end

  def success

  end

  private

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  def create_order(cart, cart_info, store)
    order = Order.new
    order.uid = cart.user.uid
    order.user_id = cart.user.id
    order.items_price = cart.total
    order.ship_fee = 60
    order.total = cart.total + 60
    order.save!

    info = OrderInfo.new
    info.order_id = order.id
    info.ship_name = cart_info[:ship_name]
    info.ship_phone = cart_info[:ship_phone]
    info.ship_store_code = store.store_code
    info.ship_store_id = store.id
    info.ship_store_name = store.name
    info.ship_email = cart_info[:ship_email]
    info.save!

    cart_items = cart.cart_items
    cart_items.each do |cart_item|
      item = OrderItem.new
      item.order_id = order.id
      item.item_name = cart_item.item.name
      item.source_item_id = cart_item.item.id
      item.item_spec_id = cart_item.item_spec.id
      item.item_style = cart_item.item_spec.style
      item.item_quantity = cart_item.item_quantity
      item.item_price = cart_item.item.price
      item.save!
    end
  end

end
