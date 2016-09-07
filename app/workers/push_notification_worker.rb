class PushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(notification_id)
    @notification = Notification.find(notification_id)
    UserNotifyService.item_event_notification(@notification)
    puts "Sending notification completed"
    @notification.schedule.update_attribute(:is_execute, true)
  end
end