class Message < ActiveRecord::Base
  scope :official_messages, -> { where(message_type: Message.message_types["萌萌屋官方訊息"]).order(id: :DESC) }
  
  enum message_type: { "萌萌屋官方訊息": "0", "個人訊息": "1" }

  has_many :message_records, dependent: :destroy
  has_many :users, through: :message_records

  validates_presence_of :title, :content

  def self.messagr_type_lists
    self.message_types.to_a
  end
end