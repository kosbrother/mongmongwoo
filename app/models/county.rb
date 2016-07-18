class County < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :select_api_fields, -> { select(:id, :name) }

  TAIPEI_CITY_ID = 21

  has_many :towns
  has_many :stores

  def self.options
    County.seven_stores.pluck(:name, :id)
  end
end