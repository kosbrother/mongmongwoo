class Admin::OrderItemsController < AdminController
  before_action do
    accept_role(:manager)
  end

  def destroy
    @order_item = OrderItem.find(params[:id])
    @order_item.destroy
    order = @order_item.order
    order.update_attributes(items_price: order.calculate_items_price, ship_fee: order.calculate_ship_fee, total: order.calculate_total)
    flash[:notice] = "訂購商品已移除"
    redirect_to edit_admin_order_path(order)
  end
end