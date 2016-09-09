module Admin::AdminCartHelper
  def li_link_to_admin_cart_by_status(status)
    content_tag(:li, '' , class: set_class_to_active(status)) do
      link_to t(AdminCart::STATUS.key(status)), admin_confirm_carts_path(status: status)
    end
  end

  def set_class_to_active(status)
    params[:status].to_i == status ? 'active' : ''
  end

  def link_to_confirm_button(cart)
    if cart.status == "shipping"
      link_to "編號：#{cart.id} 收貨", confirm_admin_confirm_cart_path(cart), method: :post, remote: :true, class: "btn btn-primary"
    end
  end

  def supplier_name(item)
    if item
      item.taobao_supplier ? item.taobao_supplier.name : '無'
    else
      ''
    end
  end

  def admin_cart_item_quantity(cart_item)
    if cart_item.admin_cart.status == "shipping"
      render "update_quantity", item: cart_item
    elsif cart_item.admin_cart.status == "stock"
      content_tag :div do
        content_tag(:span, cart_item.actual_item_quantity, class: "#{quantity_warning_class(cart_item)}")
      end
    end
  end

  def admin_cart_table_head(admin_cart)
    if admin_cart.status == "shipping"
      content_tag(:th, "到貨量", class: "x-small")
    elsif admin_cart.status == "stock"
      content_tag(:th, "到貨量", class: "xx-small") +
      content_tag(:th, "現貨量", class: "xx-small") +
      content_tag(:th, "運送中", class: "xx-small")
    end
  end

  def stock_cart_item_table_data(cart_item)
    if cart_item.admin_cart.status == "stock"
      content_tag(:td, "#{cart_item.stock_item_quantity}") +
      content_tag(:td, "#{cart_item.shipping_item_quantity}")
    end
  end

  def admin_cart_note(admin_cart)
    if admin_cart.status == "shipping"
      render "update_note", cart: admin_cart
    elsif admin_cart.status == "stock" && admin_cart.note.present?
      content_tag(:td, "備註：#{admin_cart.note}", colspan: "10")
    end
  end

  def admin_cart_date(admin_cart)
    if admin_cart.status == "shipping"
      content_tag(:span, "訂購日期：#{admin_cart.ordered_on}")
    elsif admin_cart.status == "stock"
      content_tag(:span, "訂購日期：#{admin_cart.ordered_on}") +
      tag(:br) +
      content_tag(:span, "收貨日期：#{admin_cart.confirmed_on}")
    end
  end

  def quantity_warning_class(admin_cart_item)
    if admin_cart_item.actual_item_quantity != admin_cart_item.item_quantity
      "red-color"
    end
  end

  def li_link_to_admin_cart_by_options(active_boolean, link_name, options={status: status_params, taobao_supplier_id: nil, id: nil})
    content_tag(:li, class: "#{'active' if active_boolean}", id: "#{"cart-link-#{options[:id]}" if options[:id]}") do
      link_to link_name, admin_confirm_carts_path(options)
    end
  end
end