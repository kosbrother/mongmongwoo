class GcmOptionsGenerator
  def self.generate_item_event_options_from_notification(notification)
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

  def self.generate_personal_notify_options_from_message(message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        m_type: message.message_type
      },
      collapse_key: "updated_score"
    }
  end

  def self.generate_pick_up_options_from_message(message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        order_id: message.messageable_id
        },
      collapse_key: "updated_score"
    }
  end

  def self.generate_new_app_url_and_coupon(title, content)
    result_options = {
        data: {
            content_title: title,
            content_text: content,
            url: "https://play.google.com/store/apps/details?id=com.nineyi.shop.s008909",
            coupon: "首下載即可享優惠"
        },
        collapse_key: "updated_score"
    }
  end
end