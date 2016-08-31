module Admin::OrdersHelper
  def phone_number_looking(order)
    order.info.ship_phone
  end

  def link_to_update_order_status(order)
    status_text_list = able_change_status_to(order)

    status_text_list.collect do |status_text|
      content_tag(:li) do
        link_to status_text, update_status_admin_order_path(order, status: Order.statuses[status_text]), { method: :patch, remote: true, disable_with: '狀態更新中' }
      end
    end.join.html_safe
  end

  def able_change_status_to(order)
    case order.status
    when "新訂單"
      ["訂單取消"]
    when "處理中"
      ["訂單取消"]
    when "配送中"
      ["訂單變更"]
    when "完成取貨"
      ["退貨"]
    when "訂單變更"
      ["處理中","配送中", "訂單取消"]
    else
      []
    end
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

  def link_to_send_survey_email(order)
    if order.status == "完成取貨" && order.survey_mail
     content_tag(:span, "已寄出", class: "label label-default")
    elsif order.status == "完成取貨" && order.survey_mail.nil?
      link_to "寄出問卷", sending_survey_email_admin_mail_records_path(order), class: "btn btn-default btn-sm", method: :patch, data: { confirm: "確定寄送Email給：#{order.ship_name}？" }
    end
  end

  def blacklist_notice(order)
    if order.is_blacklisted
      content_tag(:span, "問題訂單", class: "label label-danger")
    end
  end

  def spec_requested_number(order_item)
    stock_amount = order_item.stock_amount + order_item.shipping_amount
    requested_amount = OrderItem.statuses_total_amount(order_item.item_spec_id, Order::COMBINE_STATUS_CODE)
    content_tag(:span, requested_amount, class: "#{ stock_amount < requested_amount ? 'warning' : '' }")
  end

  def link_to_restock(order)
    if Order::RESTOCK_STATUS.include?(order.status) && !(order.restock)
      link_to "入庫", restock_admin_order_path(order), method: :patch, class: "btn btn-default btn-sm"
    end
  end

  def link_to_create_refund_shopping_point(order)
    if order.status == "退貨" && ShoppingPointManager.has_refund_shopping_point?(order) == false
      link_to "退購物金", refund_shopping_point_admin_order_path(order), method: :post, class: "btn btn-default btn-sm"
    end
  end

  def link_to_post_order_to_allpay(order)
    if order.status == "訂單變更" || order.status == "處理中"
      link_to '傳送至歐付寶', post_order_to_allpay_allpay_index_path(order), remote: true, class: 'btn btn-default btn-sm inline-display', method: :post
    end
  end

  def link_to_allpay_barcode(order)
    if Order::SHOW_BARCODE_STATUS.include?(order.status) && order.allpay_transfer_id.present?
      link_to "物流單", barcode_allpay_index_path(order), class: "btn btn-default btn-sm btn-barcode", target: "_blank"
    end
  end

  def li_restock_status_link(order_status: order_status, restock_status: false, link_text: nil)
    content_tag(:li, class: restock_status.to_s == params[:restock] ? 'active' : '' ) do
      link_to link_text, status_index_admin_orders_path(status: order_status, restock: restock_status)
    end
  end

  def restock_navs(order_status: order_status)
    content_tag(:ul, class: 'nav nav-tabs') do
      li_restock_status_link(order_status: order_status, restock_status: false, link_text: "未重入庫存") +
      li_restock_status_link(order_status: order_status, restock_status: true, link_text: "已重入庫存") 
    end
  end

  def li_ship_type_link(order_status: order_status, ship_type: ship_type, link_text: nil)
    content_tag(:li, class: ship_type.to_s == params[:ship_type] ? 'active' : '' ) do
      link_to link_text, status_index_admin_orders_path(status: order_status, ship_type: ship_type)
    end
  end

  def ship_type_navs(order_status: order_status)
    content_tag(:ul, class: 'nav nav-tabs') do
      li_ship_type_link(order_status: order_status, ship_type: OrderInfo.ship_types["store_delivery"], link_text: "超商取貨") +
      li_ship_type_link(order_status: order_status, ship_type: OrderInfo.ship_types["home_delivery"], link_text: "宅配")
    end
  end

  def able_render_ship_type_navs?(order_status)
    [Order.statuses["新訂單"].to_s, Order.statuses["處理中"].to_s, Order.statuses["配送中"].to_s].include?(order_status)
  end

  def set_class_if_repurchased(order)
    if order.is_repurchased
      "info"
    end
  end

  def repurchased_notice(order)
    if order.is_repurchased
      content_tag(:span, "回購訂單", class: "label label-success")
    end
  end
end