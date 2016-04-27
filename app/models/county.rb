# == Schema Information
#
# Table name: counties
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class County < ActiveRecord::Base
  scope :seven_stores, lambda { where("store_type = ?", "4") }

  has_many :towns
  has_many :stores
end