class Admin::ConfirmCartsController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @carts = AdminCart.status(params[:status]).recent.paginate(page: params[:page])
  end

  def confirm
    shipping_cart = AdminCart.find(params[:id])
    shipping_cart.confirm_cart_items_to_stocks
    redirect_to admin_confirm_carts_path(status: AdminCart::STATUS[:stock])
  end
end