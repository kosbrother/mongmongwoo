class Admin::AdminCartItemsController < AdminController

  def create
    @cart_item = AdminCartItem.create(cart_item_params)
  end

  def update_spec

  end

  def update_quantity

  end

  def destroy
    @cart_item = current_admin_cart.admin_cart_items.find(params[:id])
    @cart_item.destroy
  end

  private

  def cart_item_params
    params.permit(:item_id, :item_spec_id, :item_quantity).merge({ admin_cart_id: current_admin_cart.id})
  end
end