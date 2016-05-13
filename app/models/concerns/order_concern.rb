module OrderConcern
  extend ActiveSupport::Concern

  included do
    after_update :notify_user_if_arrive_store
  end

  def notify_user_if_arrive_store
    if (status_changed? && status == "已到店")
      email_to_notify_pickup
      notification_to_notify_pickup
    end
  end
    
  private

  def email_to_notify_pickup
    OrderMailer.delay.notify_user_pikup_item(self)
  end

  def notification_to_notify_pickup
    if device_registration.present?
      GcmNotifyService.new.send_pickup_notification(self)
      logger.info("Sending notification to device: #{device_registration.registration_id}")
    end
  end
end