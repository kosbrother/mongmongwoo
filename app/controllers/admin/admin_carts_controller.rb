class Admin::AdminCartsController < AdminController

  def checkout
    @admin_cart_items = current_admin_cart.admin_cart_items.recent.includes({item: :specs}, :item_spec)
  end

  def submit

  end
end
