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
      link_to admin_confirm_invoices_path(status: status) do
        show_status(AdminCart::STATUS.key(status).to_s)
      end
    end
  end

  def eq_to_status?(status)
    params[:status].to_i == status ? 'active' : ''
  end

  def link_to_confirm_button(cart)
    if cart.status == "shipping"
      link_to "確認收貨", confirm_admin_confirm_invoice_path(cart), method: :post, class: "btn btn-success btn-lg"
    elsif cart.status == "stock"
      content_tag(:span, "確認已收貨", class: "label label-default")
    end
  end

  def show_status(cart_status)
    case cart_status
    when "shipping"
      return "運送中"
    when "stock"
      return "已入庫存"
    end
  end
end