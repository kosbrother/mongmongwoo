class Admin::AdminCartsController < AdminController
  helper_method :supplier_name

  def checkout
    @taobao_list = TaobaoSupplier.all
    @first_taobao_items = @taobao_list[0].items
    @first_item_specs = @first_taobao_items[0].specs
  end

  def submit
    admin_cart = AdminCart.find(params[:admin_cart_id])
    if admin_cart.admin_cart_items.any?
      admin_cart.update_attribute(:status, AdminCart::STATUS[:shipping])
      session[:admin_cart_ids].delete(params[:admin_cart_id].to_i)
      flash[:success] = "#{supplier_name(admin_cart)} 購物車已送出"
    else
      flash[:danger] = '您尚未添加商品到此購物車，因此無法送出'
    end
    redirect_to :back
  end

  private

  def supplier_name(cart)
    if cart.taobao_supplier.present?
      cart.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end
end
