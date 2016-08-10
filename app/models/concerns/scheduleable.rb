module Scheduleable
  extend ActiveSupport::Concern

  included do
    has_one :schedule, as: :scheduleable
  end

  def push_notification
    schedule = Schedule.find_by(scheduleable_id: id)
    PushNotificationWorker.perform_at(schedule.execute_time, id)
  end

  def schedule_type
    raise NotImplementedError
  end
end