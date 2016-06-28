class Admin::OrdersController < AdminController
  before_action :require_manager
  before_action :find_order, only: [:show, :update, :update_status]
  skip_before_filter  :verify_authenticity_token, only: [:allpay_create, :allpay_status]

  def index
    @orders = Order.includes(:user, info: :store, items: :item).recent.paginate(page: params[:page])
  end

  def status_index
    params[:status] ||= 0
    @orders = Order.includes(:user, info: :store, items: :item).status(params[:status]).recent.paginate(page: params[:page])    
  end

  def show
    @info = @order.info
    @items = @order.items
  end

  def update
    if @order.update(order_params)
      @result = "訂單變更完成"
    else
      @result = "訂單變更失敗"
    end

    respond_to do |format|
      format.js
    end
  end

  def update_status
    status_param = params['status'].to_i
    if @order.update_attributes(status: status_param)
      @message = "已將編號：#{@order.id} 訂單狀態設為#{@order.status}"
    else
      Rails.logger.error("error: #{@order.errors.messages}")
      flash[:alert] = "請仔細確認訂單的實際處理進度"
    end

    respond_to do |format|
      format.js
    end
  end

  def exporting_files
    @order_for_file_page = @orders_for_file = Order.includes(:user, :info).recent.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data @orders_for_file.to_csv }
    end
  end

  def search
    @search_results = Order.includes(:user, info: :store, items: :item).search_by_phone_or_email(params[:ship_phone_data], params[:ship_email_data]).paginate(:page => params[:page])
  end

  def select_orders
    current_order = Order.find(params[:id])
    @combine_orders = Order.enable_to_conbime.includes(:user, :info).search_by_phone_or_email(current_order.ship_phone, current_order.ship_email)
  end

  def combine_orders
    target_orders = Order.where(id: params[:selected_order_ids])
    target_infos = target_orders.map(&:info)
    target_items = target_orders.map(&:items).flatten

    combined_items_price = target_orders.map(&:items_price).inject(:+)
    combined_ship_fee = combined_items_price > 490 ? 0 : 60
    combined_total = combined_items_price + combined_ship_fee

    errors = []
    ActiveRecord::Base.transaction do
      order = Order.new
      order.uid = target_orders[0].uid
      order.user_id = target_orders[0].user_id
      order.items_price = combined_items_price
      order.ship_fee = combined_ship_fee
      order.total = combined_total
      order.device_registration_id = target_orders[0].device_registration_id
      order.note = "訂單編號：#{target_orders.map(&:id).join('，')} 併單"
      errors << order.errors.messages unless order.save

      info = OrderInfo.new
      info.order_id = order.id
      info.ship_name = target_infos[0].ship_name
      info.ship_phone = target_infos[0].ship_phone
      info.ship_store_code = target_infos[0].ship_store_code
      info.ship_store_id = target_infos[0].ship_store_id
      info.ship_store_name = target_infos[0].ship_store_name
      info.ship_email = target_infos[0].ship_email
      errors << info.errors.messages unless info.save

      target_items.each do |product|
        item = order.items.new
        item.item_name = product.item.name
        item.source_item_id = product.source_item_id
        item.item_spec_id = product.item_spec_id
        item.item_style = product.item_spec.style
        item.item_quantity = product.item_quantity
        item.item_price = product.item.price
        item.save
        errors << item.errors.messages unless item.save
      end

      raise ActiveRecord::Rollback if errors.present?
    end

    if errors.present?
      Rails.logger.error("error: #{errors}")
      flash.now["danger"] = "請檢查各訂單的明細資料"
      render :select_orders
    else
      target_orders.each { |order| order.update_column(:status, Order.statuses["訂單取消"]) }
      flash[:notice] = "併單已完成"
      redirect_to status_index_admin_orders_path
    end
  end

  private

  def find_order
    @order = Order.includes(:user, :info, :items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, :note, info_attributes: [:ship_phone, :ship_email, :id])
  end
end