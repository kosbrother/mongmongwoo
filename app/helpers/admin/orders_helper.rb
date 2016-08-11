module Admin::OrdersHelper
  def phone_number_looking(order)
    order.info.ship_phone
  end

  def link_to_update_order_status(status_text, order)
    link_to status_text, update_status_admin_order_path(order, status: Order.statuses[status_text]), { method: :patch, remote: true, disable_with: '狀態更新中' }
  end

  def li_status_link(options = {status: 0})
    status = options[:status]
    content_tag(:li, '' , class: set_class_to_active(status)) do
      link_to Order.statuses.key(status) + ": #{Order.count_status(status)}", status_index_admin_orders_path(options)
    end
  end

  def order_status(status_number)
    Order.statuses.key(status_number)
  end

  def logistics_status(order)
    if order.logistics_status_code
      Logistics_Status[order.logistics_status_code]
    else
      "尚未建立資料"
    end
  end

  def link_to_allpay_barcode(order)
    if order.allpay_transfer_id.present?
      link_to "物流單", barcode_allpay_index_path(order), class: "btn btn-primary", target: "_blank"
    end
  end

  def link_to_send_survey_email(order)
    if order.status == "完成取貨" && order.survey_mail
     content_tag(:span, "已寄出", class: "label label-default")
    elsif order.status == "完成取貨" && order.survey_mail.nil?
      link_to "寄出問卷調查", sending_survey_email_admin_mail_records_path(order), class: "btn btn-info", method: :patch, data: { confirm: "確定寄送Email給：#{order.ship_name}？" }
    else
      content_tag(:span, "未完成取貨", class: "label label-warning")
    end
  end

  def blacklist_warning(order)
    if order.is_blacklisted
      content_tag(:span, "問題訂單", class: "label label-danger")
    end
  end

  def check_orders_to_combine(order)
    if params[:id].to_i == order.id
      check_box_tag "selected_order_ids[]", order.id, checked: true
    else
      check_box_tag "selected_order_ids[]", order.id
    end
  end

  def link_to_combine_orders(order)
    if Order::COMBINE_STATUS.include?(order.status)
      link_to "合併其他訂單", select_orders_admin_order_path(order), class: "btn btn-default"
    end
  end

  def spec_requested_number(order_item)
    stock_amount = order_item.stock_amount + order_item.shipping_amount
    requested_amount = OrderItem.statuses_total_amount(order_item.item_spec_id, Order::COMBINE_STATUS_CODE)
    content_tag(:span, requested_amount, class: "#{ stock_amount < requested_amount ? 'warning' : '' }")
  end

  def link_to_restock(order)
    if order.restock
      content_tag(:span, "已退回庫存", class: "label label-default")
    elsif Order::RESTOCK_STATUS.include?(order.status) && !(order.restock)
      link_to "重入庫存", restock_admin_order_path(order), method: :patch, class: "btn btn-default"
    end
  end

  def li_restock_status_link(order_status: 0, restock_status: false, link_text: nil)
    content_tag(:li, class: restock_status.to_s == params[:restock] ? 'active' : '' ) do
      link_to link_text, status_index_admin_orders_path(status: order_status, restock: restock_status)
    end
  end

  def restock_navs(order_status: 0)
    content_tag(:ul, class: 'nav nav-tabs') do
      li_restock_status_link(order_status: order_status, restock_status: false, link_text: "未重入庫存") +
      li_restock_status_link(order_status: order_status, restock_status: true, link_text: "已重入庫存") 
    end
  end
end