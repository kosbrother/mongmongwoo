class User < ActiveRecord::Base
  scope :recent, -> { order(id: :DESC) }

  enum status: { disable: 0, enable: 1 }

  acts_as_paranoid

  has_secure_password validations: false

  validates :email, :presence => true,
            :uniqueness => true
  has_many :orders, dependent: :destroy
  has_many :devices, class_name: "DeviceRegistration", dependent: :destroy
  has_many :favorite_items
  has_many :favorites, through: :favorite_items, source: :item
  has_many :message_records, dependent: :destroy
  has_many :messages, through: :message_records
  has_many :logins

  self.per_page = 20

  ANONYMOUS = 31

  def self.find_or_create_from_omniauth(auth)
      where(uid: auth.id).first_or_initialize.tap do |user|
        user.uid = auth.id
        user.user_name = auth.name
        user.gender = auth.gender
        auth.email = "#{auth.uid}@mmwooo.fake.com" if auth.email.blank?
        user.email = auth.email
        user.save
      end
  end
end