module Admin::AdminCartHelper
  def render_supplier_name(cart)
    if cart.taobao_supplier.present?
      cart.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end

  def li_cart_status_link(status)
    content_tag(:li, '' , class: eq_to_status?(status)) do
      link_to AdminCart::STATUS.key(status), admin_confirm_invoices_path(status: status)
    end
  end

  def eq_to_status?(status)
    params[:status].to_i == status ? 'active' : ''
  end
end