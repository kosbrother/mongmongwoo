class Api::V3::OrdersController < ApiController
  def create
    order = Order.new
    order.uid = params[:uid]
    order.user_id =  User.find_by(uid: params[:uid]).id
    order.items_price = params[:items_price]
    order.ship_fee = params[:ship_fee]
    order.total = params[:total]

    device_of_order = DeviceRegistration.find_or_initialize_by(registration_id: params[:registration_id])
    device_of_order.user = order.user
    device_of_order.save
    order.device_registration = device_of_order
    order.save

    info = OrderInfo.new
    info.order_id = order.id
    info.ship_name = params[:ship_name]
    info.ship_phone = params[:ship_phone]
    info.ship_store_code = params[:ship_store_code]
    info.ship_store_id = params[:ship_store_id]
    info.ship_store_name = params[:ship_store_name]
    info.ship_email = params[:ship_email]
    info.save

    params[:products].each do |product|
      item = OrderItem.new
      item.order_id = order.id
      item.item_name = product[:name]
      item.source_item_id = Item.find_by(name: product[:name]).id
      item.item_spec = ItemSpec.where(item_id: item.source_item_id).find_by(style: product[:style])
      item.item_style = product[:style]
      item.item_quantity = product[:quantity]
      item.item_price = product[:price]
      item.save
    end

    OrderMailer.delay.notify_order_placed(order)

    render json: order, only: [:id]
  end

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    result_order = order.generate_result_order
    render json: result_order
  end
end