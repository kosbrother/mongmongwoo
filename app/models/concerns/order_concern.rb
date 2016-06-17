module OrderConcern
  extend ActiveSupport::Concern

  included do    
    after_update :notify_user_if_arrive_store
    after_update :create_order_blacklist
  end

  def notify_user_if_arrive_store
    if (status_changed? && status == "已到店")
      email_to_notify_pickup
      notification_to_notify_pickup
    end
  end

  def create_order_blacklist
    if (status_changed? && status == "未取訂貨")
      create_new_blacklist
      self.info.update_attribute(:is_blacklist, true)
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

  def create_new_blacklist
    OrderBlacklist.find_or_create_by(email: self.ship_email, phone: self.ship_phone) 
  end
end