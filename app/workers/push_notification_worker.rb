class PushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(notification_id)
    @notification = Notification.find(notification_id)
    GcmNotifyService.new.send_item_event_notification(@notification)
    Rails.logger.info("Sending notification")
    @notification.schedule.update_attribute(:is_execute, true)
  end
end