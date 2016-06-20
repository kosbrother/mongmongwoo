class Admin::AdminCartItemsController < AdminController
  before_action :find_cart_item, only: [:update_spec, :destroy]

  def create
    @cart_item = AdminCartItem.create(cart_item_params)
  end

  def update_spec
    @cart_item.item_spec_id = params[:spec_item_id]
    @cart_item.save
  end

  def update_quantity

  end

  def destroy
    @cart_item.destroy
  end

  private
  def find_cart_item
    @cart_item = current_admin_cart.admin_cart_items.find(params[:id])
  end

  def cart_item_params
    params.permit(:item_id, :item_spec_id, :item_quantity).merge({ admin_cart_id: current_admin_cart.id})
  end
end