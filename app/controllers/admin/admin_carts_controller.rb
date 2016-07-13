class Admin::AdminCartsController < AdminController
  before_action :require_manager

  def checkout
    @taobao_list = TaobaoSupplier.all
    @first_taobao_items = @taobao_list.includes(items: :specs)[0].items
    @first_item_specs = @first_taobao_items[0].specs
    @searched_item = Item.find(params[:item_id]) if params[:item_id]
  end

  def submit
    admin_cart = AdminCart.find(params[:admin_cart_id])
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