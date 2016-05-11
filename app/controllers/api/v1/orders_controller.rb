class Api::V1::OrdersController < ApiController
  def create
    ActiveRecord::Base.transaction do
      # 訂單 Order
      order = Order.new
      order.uid = params[:uid]
      order.user_id = User.find_by(uid: params[:uid]).id
      order.items_price = params[:items_price]
      order.ship_fee = params[:ship_fee]
      order.total = params[:total]
      # Save user_id to device_registrations table if params[:registration_id] present
      unless params[:registration_id].nil?
        device_of_order = DeviceRegistration.find_or_initialize_by(registration_id: params[:registration_id])
        device_of_order.user = order.user
        device_of_order.save!
        order.device_registration = device_of_order
      end
      order.save!

      # 收件資訊 OrderInfo
      info = OrderInfo.new
      info.order_id = order.id
      info.ship_name = params[:ship_name]
      info.ship_phone = params[:ship_phone]
      info.ship_store_code = params[:ship_store_code]
      info.ship_store_id = params[:ship_store_id]
      info.ship_store_name = params[:ship_store_name]
      info.ship_email = get_info_email(params[:ship_email],order.user)
      info.save!

      # 商品明細 OrderItem
      params[:products].each do |product|
        item = OrderItem.new
        item.order_id = order.id
        item.item_name = product[:name]
        item.source_item_id = Item.find_by(name: product[:name]).id
        item.item_spec = ItemSpec.where(item_id: item.source_item_id).find_by(style: product[:style])
        item.item_style = product[:style]
        item.item_quantity = product[:quantity]
        item.item_price = product[:price]        
        item.save!
      end
      
      OrderMailer.delay.notify_order_placed(order)
    end

    render json: "Succes：新增一筆訂單"
  end

  def index
    orders = Order.includes(:user, :info, :items).recent.page(params[:page]).per_page(20)
    render json: orders, only: [:id, :user_id, :total, :status, :uid]
  end

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    info = order.info
    items = order.items
    result_order = order.generate_result_order(order, info, items)
    render json: result_order
  end

  def user_owned_orders
    user_orders = Order.includes(:user).where("uid = ?", params[:uid]).recent.page(params[:page]).per_page(20)
    render json: user_orders, only: [:id, :uid, :total, :created_on, :status, :user_id]
  end

  private

  def get_info_email(email_param,user)
    (email_param.present?) ? email_param : user.email
  end
end