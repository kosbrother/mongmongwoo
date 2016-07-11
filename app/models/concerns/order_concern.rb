module OrderConcern
  extend ActiveSupport::Concern

  included do
    after_update :notify_user_if_arrive_store
    after_update :set_blacklisted_if_not_pickup
    after_update :update_order_status_if_goods_arrive_store_or_pickup
  end

  def notify_user_if_arrive_store
    if (status_changed? && status == "已到店")
      email_to_notify_pickup
      notification_to_notify_pickup
    end
  end

  def set_blacklisted_if_not_pickup
    if status == "未取訂貨"
      set_to_blacklist      
    end
  end

  def update_order_status_if_goods_arrive_store_or_pickup
    if logistics_status_code == Logistics_Status.key("商品配達買家取貨門市")
      self.update_columns(status: Order.statuses["已到店"])
      email_to_notify_pickup
      notification_to_notify_pickup
    elsif logistics_status_code == Logistics_Status.key("買家已到店取貨")
      self.update_columns(status: Order.statuses["完成取貨"])
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

  def set_to_blacklist
    OrderBlacklist.find_or_create_by(email: self.ship_email, phone: self.ship_phone)
    self.info.update_column(:is_blacklisted, true)
  end
end