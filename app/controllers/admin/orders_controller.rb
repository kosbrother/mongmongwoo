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
    @search_results = Order.includes(:user, info: :store, items: :item).search_by_phone_and_email(params[:ship_phone_data], params[:ship_email_data]).paginate(:page => params[:page])
  end

  private

  def find_order
    @order = Order.includes(:user, :info, :items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, :note, info_attributes: [:ship_phone, :ship_email, :id])
  end
end