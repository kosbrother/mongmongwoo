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
      link_to "確認收貨", confirm_admin_confirm_cart_path(cart), method: :post, remote: :true, class: "btn btn-success"
    elsif cart.status == "stock"
      content_tag(:span, "已收貨", class: "label label-default")
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
        content_tag(:p, "到貨數：#{cart_item.real_item_quantity}", class: "#{quantity_warning_class(cart_item)}") +
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

  def admin_cart_date(admin_cart)
    if admin_cart.status == "shipping"
      content_tag(:p, "訂購日期：#{admin_cart.ordered_on}")
    elsif admin_cart.status == "stock"
      content_tag(:p, "訂購日期：#{admin_cart.ordered_on}") +
      content_tag(:p, "收貨日期：#{admin_cart.confirmed_on}")
    end
  end

  def quantity_warning_class(admin_cart_item)
    unless admin_cart_item.real_item_quantity == admin_cart_item.item_quantity
      "red-color"
    end
  end

  def link_to_cart_index(active_boolean, link_name, options={})
    options = {status: params[:status], id: params[:id], page: params[:page]}.merge(options)
    content_tag(:li, class: "#{'active' if active_boolean}", id: "cart-link-#{options[:id]}") do
      link_to link_name, admin_confirm_carts_path(status: options[:status], id: options[:id], page: options[:page])
    end
  end
end