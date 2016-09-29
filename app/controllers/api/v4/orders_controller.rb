class Api::V4::OrdersController < ApiController
  def checkout
    if params[:user_id] && params[:user_id].to_i != User::ANONYMOUS
      user = User.find(params[:user_id])
      user_shopping_points_amount = ShoppingPointManager.new(user).total_amount
      items_price_amount = (params[:items_price].to_i * 0.1).round
      shopping_point_amount = [user_shopping_points_amount, items_price_amount].min
    else
      shopping_point_amount = 0
    end

    render status: 200, json: {data: {shopping_point_amount: shopping_point_amount}}
  end

  def check_pickup_record
    if params[:user_id].to_i == User::ANONYMOUS
      has_pick_up_records_within_30_days = Order.joins(:info).status(Order.statuses["未取訂貨"]).exists?(['(order_infos.ship_email = :ship_email OR order_infos.ship_phone = :ship_phone) AND orders.created_at > :starting_time', ship_email: params[:ship_email], ship_phone: params[:ship_phone], starting_time: (Time.current - 30.days)])
    else
      user = User.find(params[:user_id])
      has_pick_up_records_within_30_days = user.orders.status(Order.statuses["未取訂貨"]).exists?(['orders.created_at > :starting_time', starting_time: (Time.current - 30.days)])
    end

    if has_pick_up_records_within_30_days
      render status: 203, json: {error: {code: 203, message: "抱歉，您於一個月內，已有未取訂貨紀錄，運送方式請選擇宅配。"}}
    else
      render status: 200, json: {data: "success"}
    end
  end

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
      @order.ship_type = params[:ship_type] if params[:ship_type]
      device_of_order = DeviceRegistration.find_by(registration_id: params[:registration_id])
      @order.device_registration = device_of_order
      errors << @order.errors.messages unless @order.save
      raise ActiveRecord::Rollback if @order.invalid?

      info = OrderInfo.new
      info.order_id = @order.id
      info.ship_name = params[:ship_name]
      info.ship_phone = params[:ship_phone]
      info.ship_email = params[:ship_email]
      if info.is_order_store_delivery?
        info.ship_store_code = params[:ship_store_code]
        info.ship_store_id = params[:ship_store_id]
        info.ship_store_name = params[:ship_store_name]
      elsif info.is_home_delivery?
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
      OrderMailer.delay.notify_order_placed(@order) if (@order.store_delivery? || @order.home_delivery?)
      render status: 200, json: {data: @order.as_json(only: [:id])}
    end
  end

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    result_order = order.generate_result_order
    render status: 200, json: {data: result_order}
  end

  def by_user_email
    orders = Order.joins(:user).where('users.email = :email', email: params[:email]).exclude_unpaid_credit_card_orders.recent
    data = orders.as_json(only: [:id, :total, :created_at, :status, :user_id])
    data.each{|data| data["created_on"] = data["created_at"].strftime("%Y-%m-%d")}
    render status: 200, json: {data: data}
  end

  def by_email_phone
    orders = Order.joins(:info).where("order_infos.ship_email = :ship_email AND order_infos.ship_phone = :ship_phone", ship_email: params[:ship_email], ship_phone: params[:ship_phone]).exclude_unpaid_credit_card_orders.recent
    data = orders.as_json(only: [:id, :total, :created_at, :status, :user_id])
    data.each{|data| data["created_on"] = data["created_at"].strftime("%Y-%m-%d")}
    render status: 200, json: {data: data}
  end
end