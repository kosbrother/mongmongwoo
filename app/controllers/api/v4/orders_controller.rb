class Api::V4::OrdersController < ApiController
  def create
    errors = []

    ActiveRecord::Base.transaction do
      @order = Order.new
      if params[:email]
        @order.user_id =  User.find_by(email: params[:email]).id  if User.find_by(email: params[:email])
      elsif params[:uid]
        @order.uid = params[:uid]
        @order.user_id = User.find_by(uid: params[:uid]).id if User.find_by(uid: params[:uid])
      end
      @order.items_price = params[:items_price]
      @order.ship_fee = params[:ship_fee]
      @order.total = params[:total]
      @order.ship_type = params[:ship_type]
      device_of_order = DeviceRegistration.find_by(registration_id: params[:registration_id])
      @order.device_registration = device_of_order
      errors << @order.errors.messages unless @order.save
      raise ActiveRecord::Rollback if @order.invalid?

      info = OrderInfo.new
      info.order_id = @order.id
      info.ship_name = params[:ship_name]
      info.ship_phone = params[:ship_phone]
      info.ship_email = params[:ship_email]
      if info.order.is_store_delivery?
        info.ship_store_code = params[:ship_store_code]
        info.ship_store_id = params[:ship_store_id]
        info.ship_store_name = params[:ship_store_name]
      elsif info.order.is_home_delivery?
        info.ship_address = params[:ship_address]
      end
      errors << info.errors.messages unless info.save

      if params[:products].blank?
        errors << {empty_params: ["params[products] is blank"]}
      else
        params[:products].each do |product|
          item = OrderItem.new
          item.order_id = @order.id
          item.item_name = product[:name]
          item.source_item_id = product[:product_id]
          item.item_spec_id = product[:spec_id]
          item.item_style = product[:style]
          item.item_quantity = product[:quantity]
          item.item_price = product[:price]
          errors << item.errors.messages unless item.save
        end
      end

      raise ActiveRecord::Rollback if errors.present?
    end

    attributes_errors = []
    products_errors = []

    errors.each do |error|
      if error.has_key?(:unable_to_buy)
        products_errors << error[:unable_to_buy][0]
      else
        error.each_value { |value| attributes_errors << value[0] }
      end
    end

    if attributes_errors.present?
      Rails.logger.error("error: #{attributes_errors.join("，")}")
      render status: 400, json: attributes_errors.join("，")
    elsif products_errors.present?
      render status: 203, json: {data: {unable_to_buy: products_errors}}
    else
      ShoppingPointManager.spend_shopping_points(@order, params[:shopping_points_amount].to_i)
      OrderMailer.delay.notify_order_placed(@order)
      render status: 200, json: {data: @order.as_json(only: [:id])}
    end
  end

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    result_order = order.generate_result_order
    render status: 200, json: {data: result_order}
  end
end