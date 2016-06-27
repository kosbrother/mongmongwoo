class Admin::AdminCartsController < AdminController

  def checkout
    @taobao_list = TaobaoSupplier.all
    @first_taobao_items = @taobao_list[0].items
    @first_item_specs = @first_taobao_items[0].specs
  end

  def submit
    admin_cart = AdminCart.find(params[:admin_cart_id])
    admin_cart.update_attribute(:status, AdminCart::STATUS[:shipping])
    session[:admin_cart_ids].delete(params[:admin_cart_id].to_i)
    redirect_to :back
  end
end
