class Admin::ConfirmCartsController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @carts = AdminCart.status(params[:status]).recent.paginate(page: params[:page])
  end

  def confirm
    @shipping_cart = AdminCart.find(params[:id])
    @shipping_cart.confirm_cart_items_to_stocks
    @message = "#{@shipping_cart.taobao_supplier_name}的編號：#{@shipping_cart.id}訂單已確認收貨"
  end

  def export_shipping_list
    @shipping_list = AdminCart.status(AdminCart.statuses['shipping']).recent
  end
end