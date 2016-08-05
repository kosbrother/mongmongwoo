module OrderHelper
  def order_status(status)
    case status
    when "訂單變更"
      content_tag(:span, status, class: 'order-status status-warning')
    when "訂單取消" || "未取訂單" || "退貨"
      content_tag(:span, status, class: 'order-status status-cancel')
    else
      content_tag(:span, status, class: 'order-status status-success')
    end
  end
end