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
      self.gcm.send_notification(registration_ids, options)
    end
  end

  def send_pickup_notification(device_id, order)
    registration_id = device_id.split
    options = generate_options_for_pickup(order)
    self.gcm.send(registration_id, options)
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
        item_price: notification.item.price
        },
      collapse_key: "updated_score"
    }
    return result_options
  end

  def generate_options_for_pickup(order)
    result_options = {
      data: {
        content_title: "萌萌屋取貨通知",
        content_text: "#{order.ship_name} 您好，您訂購的商品已送達#{order.ship_store_name}門市，請於七日內完成取貨。若有任何問題，請聯繫萌萌屋客服。"
        },
      collapse_key: "updated_score"
    }
    return result_options
  end
end