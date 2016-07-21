class Message < ActiveRecord::Base
  enum message_type: { "萌萌屋官方訊息": "0", "個人訊息": "1" }

  validates_presence_of :title, :content

  has_many :message_records, dependent: :destroy
  has_many :users, through: :message_records

  scope :official_messages, -> { where(message_type: Message.message_types["萌萌屋官方訊息"]).order(created_at: :DESC) }
  scope :select_api_fields, -> { select(:id, :message_type, :title, :content, :created_at) }
  scope :personal_and_official, -> (user) { joins('LEFT JOIN `message_records` ON message_records.message_id = messages.id').where('message_type = :message_type OR user_id = :user_id', message_type: Message.message_types["萌萌屋官方訊息"], user_id: user.id) }

  def self.message_type_lists
    message_types.to_a
  end
end