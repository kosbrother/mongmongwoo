module OrderHelper
  def order_status(status)
    if status == "訂單變更"
      class_name = 'order-status status-warning'
    elsif Order::FAIL_STATUS.include?(status)
      class_name = 'order-status status-cancel'
    else
      class_name = 'order-status status-success'
    end
    content_tag(:span, status, class: class_name)
  end
end