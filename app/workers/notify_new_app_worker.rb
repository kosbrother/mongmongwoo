class NotifyNewAppWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(notification_id)
    @notification = Notification.find(notification_id)
    UserNotifyService.new_app_notification(@notification)
    puts "Notify New APP completed"
    @notification.schedule.update_attribute(:is_execute, true)
  end
end