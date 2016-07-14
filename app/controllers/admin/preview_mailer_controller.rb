class Admin::PreviewMailerController < AdminController
  before_action :require_manager
  layout "mailer"

  def order_placed
    params[:id] ? @order = Order.find(params[:id]) : @order = Order.last
    @order_items = @order.items.includes(:item_spec)
    @order_info = @order.info
    render 'order_mailer/notify_order_placed'
  end
end