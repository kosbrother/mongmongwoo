class Admin::OrderItemsController < AdminController
  before_action :require_manager

  def destroy
    @order_item = OrderItem.find(params[:id])
    @order_item.destroy
    @message = "訂購商品已移除"
  end
end