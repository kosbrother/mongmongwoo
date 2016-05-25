# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string(255)
#  real_name  :string(255)
#  gender     :string(255)
#  address    :string(255)
#  uid        :string(255)
#  phone      :string(255)
#  status     :integer          default(1)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

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
