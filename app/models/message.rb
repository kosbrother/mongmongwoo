class Message < ActiveRecord::Base
  include AndroidApp

  enum message_type: { "萌萌屋官方訊息": "0", "個人訊息": "1" }

  validates_presence_of :title, :content

  has_many :message_records, dependent: :destroy
  has_many :users, through: :message_records
  belongs_to :messageable, polymorphic: true

  scope :official_messages, -> { where(message_type: Message.message_types["萌萌屋官方訊息"]).order(created_at: :DESC) }
  scope :select_api_fields, -> { select(:id, :message_type, :title, :content, :created_at) }
  scope :user_messages, -> (user_id) { joins('LEFT JOIN message_records ON message_records.message_id = messages.id').where('message_type = :message_type OR message_records.user_id = :user_id', message_type: Message.message_types["萌萌屋官方訊息"], user_id: user_id).order(created_at: :DESC) }

  def self.message_type_lists
    message_types.to_a
  end

  def self.user_has_message?(user, messageable)
    joins(:message_records).where(message_records: { user_id: user.id }, messageable: messageable).exists?
  end

  def able_path
    case messageable_type
    when ShoppingPointCampaign.name
      shopping_point_campaigns_path
    end
  end
end