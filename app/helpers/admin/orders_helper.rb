module Admin::OrdersHelper
  def phone_number_looking(order)
    order.info.ship_phone
  end

  def link_to_update_order_status(status_text, order)
    link_to status_text, update_status_admin_order_path(order, status: Order.statuses[status_text]), { method: :patch, remote: true, disable_with: '狀態更新中' }
  end

  def li_status_link(status)
    content_tag(:li, '' , class: eq_to_status?(status)) do
      link_to Order.statuses.key(status) + ": #{Order.count_status(status)}", status_index_admin_orders_path(status: status)
    end
  end

  def eq_to_status?(status)
    params[:status].to_i == status ? 'active' : ''
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

  def create_allpay_index_button(order)
    if order.logistics_status_code.nil?
      button_to "傳送至歐付寶", create_allpay_index_path(order), remote: true, class: "btn btn-primary"
    else
      content_tag(:span, '已傳送至歐付寶', class: "label label-default")
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
    if order.check_blacklists || order.check_data_format
      content_tag(:span, "問題訂單", class: "label label-danger")
    end
  end
end