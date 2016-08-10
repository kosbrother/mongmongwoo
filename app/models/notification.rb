class Notification < ActiveRecord::Base
  include Scheduleable

  enum schedule_type: { on_shelf: "on shelf" }

  validates_presence_of :item_id, on: :create
  validates_presence_of :content_title, on: :create
  validates_presence_of :content_text, on: :create

  belongs_to :category
  belongs_to :item

  scope :recent, -> { order(id: :DESC) }

  def send_content_pic
    self.item.cover.url
  end

  def schedule_type
    Notification.schedule_types[:on_shelf]
  end
end