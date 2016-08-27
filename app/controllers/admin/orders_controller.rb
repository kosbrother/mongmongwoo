class Admin::OrdersController < AdminController
  before_action :require_manager
  before_action :find_order, only: [:update, :update_status, :refund_shopping_point]
  skip_before_filter  :verify_authenticity_token, only: [:allpay_create, :allpay_status]

  def index
    @orders = Order.includes(:user).recent.paginate(page: params[:page])
  end

  def status_index
    params[:status] ||= Order.statuses["新訂單"]
    query_hash = {status: params[:status]}
    includes_array = [:user]

    if params[:restock]
      restock = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(params[:restock])
      query_hash = query_hash.merge(restock: restock)
    end
    includes_array << :shopping_point_records if params[:status] == Order.statuses["退貨"].to_s
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
    @search_results = Order.includes(:user, info: :store, items: [:item, item_spec: :stock_spec]).search_by_search_terms(@search_term).paginate(:page => params[:page])
  end

  def open_barcode_tab
    @order_list = Order.includes(:user, :items).status(Order.statuses['處理中']).allpay_transfer_id_present.recent
  end

  def change_status_to_transfer
    @order_list = Order.includes(:user, :items).status(Order.statuses['處理中']).allpay_transfer_id_present.recent
    @order_list.each do |order|
      order.update_attribute(:status, Order.statuses["配送中"])
    end
    redirect_to status_index_admin_orders_path(status: Order.statuses["處理中"])
  end

  def export_processing_order_list
    @order_list = Order.includes(:user, :items).status(Order.statuses['處理中']).allpay_transfer_id_present.recent

    @order_list.each do |order|
      order.update_attribute(:status, Order.statuses["配送中"])
    end

    @sheet_name = '處理中訂單清單'
    render 'export_order_list'
  end

  def export_returned_order_list
    @order_list = Order.includes(:user, :items).status(Order.statuses['退貨']).where(restock: false)
    @sheet_name = '退貨訂單清單(尚未入庫)'

    render 'export_order_list'
  end

  def restock
    order = Order.includes(items: [item_spec: :stock_spec]).find(params[:id])
    order.restock_order_items
    flash[:notice] = "訂單商品已退回庫存"
    redirect_to status_index_admin_orders_path(status: Order.statuses[order.status], restock: false)
  end

  def update_to_processing
    new_orders = Order.status(Order.statuses["新訂單"])
    new_orders.each do |order|
      order.update_attribute(:status, Order.statuses["處理中"]) if order.all_able_to_pack?
    end

    redirect_to status_index_admin_orders_path(status: Order.statuses["新訂單"])
  end

  def refund_shopping_point
    if @order.user_id == User::ANONYMOUS
      flash[:danger] = "該訂單為匿名購買，因此無法產生購物金"
    else
      ShoppingPointManager.create_refund_shopping_point(@order)
      flash[:notice] = "訂單編號#{@order.id} 退貨購物金已產生"
    end

    redirect_to :back
  end

  private

  def find_order
    @order = Order.includes(:user, :info, :items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, :note, info_attributes: [:ship_phone, :ship_email, :id, :ship_store_code])
  end

  def search_params
    params.require(:order_search_term).permit(:order_id, :ship_email, :ship_phone)
  end
end