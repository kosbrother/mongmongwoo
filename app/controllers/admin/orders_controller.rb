class Admin::OrdersController < AdminController
  before_action :require_manager
  before_action :find_order, only: [:show, :update, :update_status]
  skip_before_filter  :verify_authenticity_token, only: [:allpay_create, :allpay_status]

  def index
    @orders = Order.includes(:user, info: :store, items: :item).recent.paginate(page: params[:page])
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
      redirect_to status_index_admin_orders_path(status: Order.statuses[@order.status])
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
    Order.combine_orders(params[:selected_order_ids])
    flash[:notice] = "併單已完成"
    redirect_to status_index_admin_orders_path
  end

  private

  def find_order
    @order = Order.includes(:user, :info, :items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, :note, info_attributes: [:ship_phone, :ship_email, :id, :ship_store_code])
  end
end