class GcmOptionsGenerator
  def self.generate_options_from_notification(notification)
    result_options = {
      data: {
        content_title: notification.content_title,
        content_text: notification.content_text,
        content_pic: notification.send_content_pic,
        item_id: notification.item_id,
        item_name: notification.item.name,
        item_price: notification.item.price,
        category_id: notification.category_id,
        category_name: notification.category.name
        },
      collapse_key: "updated_score"
    }
  end

  def self.generate_options_from_message(message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        m_type: message.message_type
      },
      collapse_key: "updated_score"
    }
  end

  def self.generate_options_from_order_id_and_message(order_id, message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        order_id: "#{order_id}"
        },
      collapse_key: "updated_score"
    }
  end
end