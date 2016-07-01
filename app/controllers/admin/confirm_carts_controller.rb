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
      save_stock_and_stock_spec(cart_item)
    end
  end

  def save_stock_and_stock_spec(cart_item)
    stock = Stock.find_or_initialize_by(item_id: cart_item.item_id)
    stock_spec = StockSpec.find_or_initialize_by(item_spec_id: cart_item.item_spec_id)

    if stock.new_record? && stock_spec.new_record?
      stock.item = cart_item.item
      stock.save

      stock.stock_specs << stock_spec
      stock_spec.item_spec = cart_item.item_spec
      stock_spec.amount = cart_item.item_quantity
      stock_spec.save
    elsif stock_spec.new_record?
      stock.stock_specs << stock_spec
      stock_spec.item_spec = cart_item.item_spec
      stock_spec.amount = cart_item.item_quantity
      stock_spec.save
    else
      stock_spec.amount += cart_item.item_quantity
      stock_spec.save
    end
  end
end