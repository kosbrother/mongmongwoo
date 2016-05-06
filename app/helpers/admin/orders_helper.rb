module Admin::OrdersHelper
  def paid_status(order)
    (order.is_paid) == true ? "完成付款" : "尚未付款"
  end

  def order_status(status)
    case status
    when "order_placed"
      return "新增訂單"
    when "item_shipping"
      return "已出貨"
    when "item_shipped"
      return "完成取貨"
    when "order_cancelled"
      return "訂單取消"
    end
  end

  def phone_number_looking(order)
    order.info.ship_phone
  end

  def link_to_update_order_status(status_text, order)
    link_to status_text, update_status_admin_order_path(order, status: Order.statuses[status_text]), { method: :patch, remote: true, disable_with: '狀態更新中' }
  end

  def li_status_link(status)
    content_tag(:li, '' , class: eq_to_status?(status)) do
      link_to Order.statuses.key(status) + ": #{Order.count_status(status)}", admin_orders_path(status: status)
    end
  end

  def eq_to_status?(status)
    params[:status].to_i == status ? 'active' : ''
  end

end