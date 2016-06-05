class Api::V2::OrdersController < ApiController
  # TODO 重構整理

  def show
    order = Order.includes(:user, :info, :items).find(params[:id])
    info = order.info
    items = order.items
    result_order = order.generate_result_order
    render json: result_order
  end

  def user_owned_orders
    user_orders = Order.includes(:user).where("uid = ?", params[:uid]).recent.page(params[:page]).per_page(20)
    # result_user_orders = []

    render json: user_orders, only: [:id, :uid, :total, :created_on, :status, :user_id]
  end
end