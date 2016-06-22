module Admin::AdminCartHelper
  def render_supplier_name(cart)
    if cart.taobao_supplier_id > 0
      cart.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end
end