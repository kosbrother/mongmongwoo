class Admin::OrdersController < AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_order, only: [:update, :update_status, :refund_shopping_point]
  skip_before_filter  :verify_authenticity_token, only: [:allpay_create, :allpay_status]

  def index
    @orders = Order.includes(:user).recent.paginate(page: params[:page])
  end

  def status_index
    params[:status] ||= Order.statuses["新訂單"]
    params[:ship_type] ||= Order.ship_types["store_delivery"]
    query_hash = {status: params[:status], ship_type: params[:ship_type]}
    includes_array = [:user]

    if params[:restock]
      restock = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(params[:restock])
      query_hash = query_hash.merge(restock: restock)
    end
    includes_array << :info if params[:status] == Order.statuses["完成取貨"].to_s

    @orders = Order.includes(includes_array).where(query_hash).recent.paginate(page: params[:page])
  end

  def edit
    @order = Order.includes(items: [:item, :item_spec]).find(params[:id])
  end

  def show
    @order = Order.includes(:info, items: [:item, :item_spec]).find(params[:id])
  end

  def update
    if @order.update(order_params)
      flash[:notice] = "訂單編號：#{@order.id}變更完成"
      redirect_to :back
    else
      flash.now[:danger] = "請確認資料是否正確"
      render :edit
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
  end

  def exporting_files
    @order_for_file_page = @orders_for_file = Order.includes(:user, :info).recent.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data @orders_for_file.to_csv }
    end
  end

  def search
    @search_term = search_params
    query_hash = {}
    query_hash["id"] = search_params["order_id"] if search_params["order_id"].present?
    if search_params["ship_email"].present? || search_params["ship_phone"].present?
      query_hash["order_infos"] ={}
      query_hash["order_infos"]["ship_email"] = search_params["ship_email"] if search_params["ship_email"].present?
      query_hash["order_infos"]["ship_phone"] = search_params["ship_phone"] if search_params["ship_phone"].present?
    end

    @search_results = Order.includes(:user, :info).where(query_hash).paginate(:page => params[:page])
  end

  def open_barcode_tab
    @order_list = Order.includes(:user, :items).status(Order.statuses['處理中']).allpay_transfer_id_present.recent
  end

  def change_status_to_transfer
    @order_list = get_orders_by_params

    @order_list.each do |order|
      order.update_attribute(:status, Order.statuses["配送中"])
    end
    redirect_to status_index_admin_orders_path(status: Order.statuses["處理中"], ship_type: params[:ship_type])
  end

  def export_processing_order_list
    @order_list = get_orders_by_params
    @picking_list_index_hash = get_picking_list_index_hash(@order_list)

    @sheet_name = '處理中訂單清單'
    render 'export_order_list'
  end

  def export_changed_order
    order = Order.find(params[:id])
    @order_list = [order]
    @picking_list_index_hash = get_picking_list_index_hash(@order_list)
    @sheet_name = '變更中訂單'
    render 'export_order_list'
  end

  def export_returned_order_list
    @order_list = Order.includes(:user, :items).status(Order.statuses['退貨']).where(ship_type: params[:ship_type], restock: false)
    @picking_list_index_hash = get_picking_list_index_hash(@order_list)
    @sheet_name = '退貨訂單清單(尚未入庫)'
    render 'export_order_list'
  end

  def export_home_delivery_order_list
    order_list = Order.includes(:user).status(Order.statuses['處理中']).home_delivery
    file_name = "home_delivery_order_list.xls"
    spreadsheet = OrderDeliveryExcelGenerator.generate_home_delivery_order_xls(order_list)
    send_data(spreadsheet, type: "application/vnd.ms-excel", filename: file_name)
  end

  def restock
    order = Order.includes(items: [item_spec: :stock_spec]).find(params[:id])
    order.restock_order_items
    flash[:notice] = "訂單商品已退回庫存"
    redirect_to status_index_admin_orders_path(status: Order.statuses[order.status], restock: false, ship_type: params[:ship_type])
  end

  def update_to_processing
    new_orders = Order.status(Order.statuses["新訂單"]).where(ship_type: params[:ship_type])
    new_orders.each do |order|
      order.update_attribute(:status, Order.statuses["處理中"]) if order.all_able_to_pack? && order.is_paid_if_by_credit_card
    end

    redirect_to :back
  end

  private

  def find_order
    @order = Order.includes(:user, :info, :items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, :note, info_attributes: [:ship_phone, :ship_email, :id, :ship_store_code, :ship_address])
  end

  def search_params
    params.require(:order_search_term).permit(:order_id, :ship_email, :ship_phone)
  end

  def get_orders_by_params
    query_data = {}

    if params[:ship_type] == Order.ship_types["store_delivery"].to_s
      query_data = ['orders.allpay_transfer_id IS NOT NULL AND orders.ship_type = :ship_type', ship_type: Order.ship_types["store_delivery"]]
    elsif params[:ship_type] == Order::HOME_DELIVERY_CODE.map(&:to_s)
      query_data = query_data.merge(ship_type: Order::HOME_DELIVERY_CODE)
    end

    Order.includes(:user, :items).status(Order.statuses['處理中']).where(query_data).recent
  end

  def get_picking_list_index_hash(order_list)
    Hash[order_list.map.with_index { |order, index| [order.id, (index + 1)] }]
  end
end