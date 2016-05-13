module Notify
  extend ActiveSupport::Concern

  def notify_after_update_order_status(order)
    if order.reload.status == "已到店"
      email_to_notify_pickup(order)
      notification_to_notify_pickup(order)
    end
  end
    
  private

  def email_to_notify_pickup(order)
    OrderMailer.delay.notify_user_pikup_item(order)
  end

  def notification_to_notify_pickup(order)
    if order.device_registration
      GcmNotifyService.new.send_pickup_notification(order)
      logger.info("Sending notification to device: #{order.device_registration.registration_id}")
    end
  end
end