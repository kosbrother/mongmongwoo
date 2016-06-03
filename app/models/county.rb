class County < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }

  has_many :towns
  has_many :stores
end