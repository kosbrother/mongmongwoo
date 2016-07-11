module Admin::AdminCartHelper
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
      link_to "確認收貨", confirm_admin_confirm_cart_path(cart), method: :post, class: "btn btn-success"
    elsif cart.status == "stock"
      content_tag(:span, "確認已收貨", class: "label label-default")
    end
  end

  def supplier_name(item)
    if item
      item.taobao_supplier ? @searched_item.taobao_supplier.name : '無'
    else
      ''
    end
  end

  def admin_cart_item_quantity(cart_item)
    if cart_item.admin_cart.status == "shipping"
      render "update_quantity", item: cart_item
    elsif cart_item.admin_cart.status == "stock"
      content_tag :div do
        content_tag(:p, "現貨數：#{cart_item.stock_item_quantity}") +
        content_tag(:p, "運送中：#{cart_item.shipping_item_quantity}")
      end
    end
  end

  def admin_cart_note(admin_cart)
    if admin_cart.status == "shipping"
      render "update_note", cart: admin_cart
    elsif admin_cart.status == "stock"
      admin_cart.note
    end
  end
end