class GcmNotifyService
  require 'gcm'

  attr_reader :gcm

  def initialize
    @gcm = GCM.new(ENV["GCM_KEY"])
  end

  def send_item_event_notification(notification)
    options = generate_options_for_item(notification)
    DeviceRegistration.select(:id, :registration_id).find_in_batches do |ids|
      registration_ids = ids.map(&:registration_id)
      @gcm.send_notification(registration_ids, options)
    end
  end

  def send_pickup_notification(order, message)
    device_id = order.device_registration.registration_id
    registration_id = [device_id]
    options = generate_options_for_pickup(order, message)
    @gcm.send(registration_id, options)
  end

  def send_message_notification(device_id, message)
    registration_id = [DeviceRegistration.find(device_id).registration_id]
    options = generate_options_for_send_message(message)
    @gcm.send(registration_id, options)
  end

  private

  def generate_options_for_item(notification)
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

  def generate_options_for_pickup(order, message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        order_id: "#{order.id}"
        },
      collapse_key: "updated_score"
    }
  end

  def generate_options_for_send_message(message)
    result_options = {
      data: {
        content_title: message.title,
        content_text: message.content,
        m_type: message.message_type
      },
      collapse_key: "updated_score"
    }
  end
end