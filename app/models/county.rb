class County < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :select_api_fields, -> { select(:id, :name) }

  OPTIONS = County.seven_stores.collect{|c| [c.name, c.id]}

  has_many :towns
  has_many :stores
end