class Admin::OrdersController < AdminController
  before_action :require_manager
  before_action :find_order, only: [:show, :update, :update_status]
  skip_before_filter  :verify_authenticity_token, only: [:allpay_create, :allpay_status]

  def index
    @orders = Order.includes(:user, info: :store, items: [:item, item_spec: :stock_spec]).recent.paginate(page: params[:page])
  end

  def status_index
    params[:status] ||= 0
    @orders = Order.includes(:user, info: :store, items: [:item, item_spec: :stock_spec]).status(params[:status]).recent.paginate(page: params[:page])
  end

  def edit
    @order = Order.includes(:info).find(params[:id])
  end

  def show
    @info = @order.info
    @items = @order.items
  end

  def update
    if @order.update(order_params)
      flash[:notice] = "訂單編號：#{@order.id}變更完成"
      redirect_to status_index_admin_orders_path(status: Order.statuses[@order.status], anchor: "order-id-#{@order.id}")
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

  def select_orders
    current_order = Order.find(params[:id])
    @combine_orders = Order.enable_to_conbime.includes(:user, :info).search_by_phone_or_email(current_order.ship_phone, current_order.ship_email)
  end

  def combine_orders
    Order.combine_orders(params[:selected_order_ids])
    flash[:notice] = "併單已完成"
    redirect_to status_index_admin_orders_path
  end

  def export_order_list
    @order_list = Order.includes(:user, :items).status(Order.statuses['處理中']).recent
  end

  def restock
    order = Order.includes(items: [item_spec: :stock_spec]).find(params[:id])
    order.restock_order_items
    order.update_attribute(:is_return, true)
    flash[:notice] = "訂單商品已退回庫存"
    redirect_to status_index_admin_orders_path(status: Order.statuses[order.status], anchor: "order-id-#{order.id}")
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