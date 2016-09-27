class Admin::AdminCartsController < AdminController
  before_action do
    accept_role(:manager)
  end

  def checkout
    @searched_item = Item.find(params[:item_id]) if params[:item_id]
  end

  def submit
    admin_cart = AdminCart.find(params[:admin_cart_id])
    admin_cart.taobao_order_id = params[:taobao_order_id]
    if admin_cart.set_to_shipping
      session[:admin_cart_ids].delete(params[:admin_cart_id].to_i)
      flash[:success] = "#{admin_cart.taobao_supplier_name} 購物車已送出"
    else
      flash[:danger] = '您尚未添加商品到此購物車，因此無法送出'
    end
    redirect_to :back
  end

  def note
    @cart = AdminCart.find(params[:id])
    @cart.update(note: params[:note])
  end
end