class Admin::ConfirmCartsController < AdminController
  before_action :require_manager

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    @carts = AdminCart.current_status(params[:status]).recent.paginate(page: params[:page])
  end

  def confirm
    shipping_cart = AdminCart.current_status(AdminCart::STATUS[:shipping]).find(params[:id])
    cart_items = shipping_cart.admin_cart_items

    cart_items.each do |cart_item|
      stock = Stock.find_by(item_id: cart_item.item_id)
      stock_spec = StockSpec.find_by(item_spec_id: cart_item.item_spec_id)

      if stock && stock_spec
        stock_spec.amount += cart_item.item_quantity
        stock_spec.save
      elsif stock && stock_spec.nil?
        new_stock_spec = stock.stock_specs.new
        new_stock_spec.item_spec = cart_item.item_spec
        new_stock_spec.amount = cart_item.item_quantity
        new_stock_spec.save
      else
        new_stock = Stock.new
        new_stock.item = cart_item.item
        new_stock.save

        new_stock_spec = new_stock.stock_specs.new
        new_stock_spec.item_spec = cart_item.item_spec
        new_stock_spec.amount = cart_item.item_quantity
        new_stock_spec.save
      end
    end

    shipping_cart.update_attribute(:status, AdminCart::STATUS[:stock])

    redirect_to admin_confirm_carts_path(status: AdminCart::STATUS[:stock])
  end
end