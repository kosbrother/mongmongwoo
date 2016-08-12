class Notification < ActiveRecord::Base
  include Scheduleable

  enum schedule_type: { on_shelf_schedule: "on_shelf_schedule" }

  validates_presence_of :item_id, on: :create
  validates_presence_of :content_title, on: :create
  validates_presence_of :content_text, on: :create

  belongs_to :category
  belongs_to :item

  scope :recent, -> { order(id: :DESC) }
  scope :with_schedule, -> { joins(:schedule).select('notifications.*, schedules.execute_time AS execute_time, schedules.schedule_type AS schedule_type') }
  scope :by_execute, -> (execute_status_param) { where(schedules: { is_execute: execute_status_param }) }

  def send_content_pic
    self.item.cover.url
  end

  def schedule_type
    Notification.schedule_types[:on_shelf_schedule]
  end
end