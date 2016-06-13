class User < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  enum status: { disable: 0, enable: 1 }

  acts_as_paranoid

  validates_presence_of :user_name, :uid, :email
  validates_presence_of :real_name, allow_blank: true
  validates_presence_of :gender, allow_blank: true
  validates_presence_of :address, allow_blank: true
  validates_presence_of :phone, allow_blank: true

  has_many :orders, dependent: :destroy
  has_many :devices, class_name: "DeviceRegistration", dependent: :destroy
  has_many :favorite_items
  has_many :favorites, through: :favorite_items, source: :item
  has_many :message_records, dependent: :destroy
  has_many :messages, through: :message_records

  self.per_page = 20

  ANONYMOUS = 31

  def self.find_or_create_from_omniauth(auth)
      where(uid: auth.id).first_or_initialize.tap do |user|
        user.uid = auth.id
        user.user_name = auth.name
        user.gender = auth.gender
        user.email = auth.email
        user.save
      end
  end
end