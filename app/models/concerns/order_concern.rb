module OrderConcern
  extend ActiveSupport::Concern

  included do
    after_update :notify_user_if_arrive_store
    after_update :send_satisfaction_survey_if_pickup
  end

  def notify_user_if_arrive_store
    if (status_changed? && status == "已到店")
      email_to_notify_pickup
      notification_to_notify_pickup
    end
  end

  def send_satisfaction_survey_if_pickup
    if (status_changed? && status == "完成取貨")
      email_to_satisfaction_survey
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

  def email_to_satisfaction_survey
    OrderMailer.delay.satisfaction_survey(self)
  end
end