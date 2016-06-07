class Api::V3::OrdersController < ApiController
  def create
    errors = []
    ActiveRecord::Base.transaction do
      @order = Order.new
      @order.uid = params[:uid]
      @order.user_id =  User.find_by(uid: params[:uid]).id if User.find_by(uid: params[:uid])
      @order.items_price = params[:items_price]
      @order.ship_fee = params[:ship_fee]
      @order.total = params[:total]

      device_of_order = DeviceRegistration.find_by(registration_id: params[:registration_id])
      @order.device_registration = device_of_order
      errors << @order.errors.messages unless @order.save

      info = OrderInfo.new
      info.order_id = @order.id
      info.ship_name = params[:ship_name]
      info.ship_phone = params[:ship_phone]
      info.ship_store_code = params[:ship_store_code]
      info.ship_store_id = params[:ship_store_id]
      info.ship_store_name = params[:ship_store_name]
      info.ship_email = params[:ship_email]
      errors << info.errors.messages unless info.save

      unless params[:products].blank?
        params[:products].each do |product|
          item = OrderItem.new
          item.order_id = @order.id
          item.item_name = product[:name]
          item.source_item_id = product[:product_id]
          item.item_spec_id = product[:spec_id]
          item.item_style = product[:style]
          item.item_quantity = product[:quantity]
          item.item_price = product[:price]
          item.save
          errors << item.errors.messages unless item.save
        end
      else
        errors << ["params[products] is blank"] 
      end
      raise ActiveRecord::Rollback if errors.present?
    end
    if errors.present?
      Rails.logger.error("error: #{errors}")
      render status: 400, json: {error: {message: errors}}
    else
      OrderMailer.delay.notify_order_placed(@order)
      render status: 200, json: {data: @order.as_json(only: [:id])}
    end
  end

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    result_order = order.generate_result_order
    render status: 200, json: {data: result_order}
  end

  def user_owned_orders
    user_orders = Order.includes(:user).where(uid: params[:uid]).recent.page(params[:page]).per_page(20)
    render status: 200, json: {data: user_orders.as_json(only: [:id, :uid, :total, :created_on, :status, :user_id])}
  end

  def by_email_phone
    user_orders = Order.joins(:info).where("ship_email = ? and ship_phone = ?", params[:email], params[:phone]).recent
    render status: 200, json: {data: user_orders.as_json(only: [:id, :uid, :total, :created_on, :status, :user_id])}
  end
end