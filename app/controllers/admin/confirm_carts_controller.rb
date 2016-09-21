class Admin::ConfirmCartsController < AdminController
  before_action do
    accept_role(:manager)
  end

  def index
    params[:status] ||= AdminCart::STATUS[:shipping]
    carts = AdminCart.status(params[:status]).recent
    taobao_supplier_ids = carts.pluck(:taobao_supplier_id).uniq
    @taobao_suppliers = TaobaoSupplier.where(id: taobao_supplier_ids)
    query_hash = {}
    query_hash = query_hash.merge(taobao_supplier_id: params[:taobao_supplier_id]) if params[:taobao_supplier_id]
    query_hash = query_hash.merge(id: params[:id]) if params[:id]
    @carts = carts.includes(:taobao_supplier, admin_cart_items: [:item, :item_spec]).where(query_hash).paginate(page: params[:page])
  end

  def confirm
    @shipping_cart = AdminCart.find(params[:id])
    @shipping_cart.confirm_cart_items_to_stocks
    @message = "#{@shipping_cart.taobao_supplier_name}的編號：#{@shipping_cart.id}訂單已確認收貨"
  end

  def export_shipping_list
    @shipping_list = AdminCart.status(AdminCart.statuses['shipping']).recent
  end
end