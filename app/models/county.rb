class County < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :select_api_fields, -> { select(:id, :name) }

  TAIPEI_ID = 21
  OPTIONS = County.seven_stores.pluck(:name, :id)

  has_many :towns
  has_many :stores
end