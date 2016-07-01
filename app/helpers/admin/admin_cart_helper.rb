module Admin::AdminCartHelper
  def render_supplier_name(cart)
    if cart.taobao_supplier.present?
      cart.taobao_supplier.name
    else
      '未登記淘寶商家'
    end
  end

  def li_cart_status_link(status)
    content_tag(:li, '' , class: set_class_to_active(status)) do
      link_to t(AdminCart::STATUS.key(status)), admin_confirm_carts_path(status: status)
    end
  end

  def set_class_to_active(status)
    params[:status].to_i == status ? 'active' : ''
  end

  def link_to_confirm_button(cart)
    if cart.status == "shipping"
      link_to "確認收貨", confirm_admin_confirm_cart_path(cart), method: :post, class: "btn btn-success btn-lg"
    elsif cart.status == "stock"
      content_tag(:span, "確認已收貨", class: "label label-default")
    end
  end
end