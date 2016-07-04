class Admin::ConfirmCartsController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @carts = AdminCart.status(params[:status]).recent.paginate(page: params[:page])
  end

  def confirm
    shipping_cart = AdminCart.status(AdminCart::STATUS[:shipping]).find(params[:id])
    cart_items = shipping_cart.admin_cart_items
    set_cart_items_to_stock(cart_items)
    shipping_cart.update_attribute(:status, AdminCart::STATUS[:stock])
    redirect_to admin_confirm_carts_path(status: AdminCart::STATUS[:stock])
  end

  private

  def set_cart_items_to_stock(cart_items)
    cart_items.each do |cart_item|
      stock = Stock.find_or_create_by(item_id: cart_item.item_id)
      stock_spec = stock.stock_specs.find_or_create_by(item_spec_id: cart_item.item_spec_id)

      if stock_spec.amount.present?
        stock_spec.amount += cart_item.item_quantity
      else
        stock_spec.amount = cart_item.item_quantity
      end

      stock_spec.save
    end
  end
end