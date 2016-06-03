class Store < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :concern_data, -> { select(:id, :store_code, :name, :address, :phone, :lat, :lng) }

  belongs_to :county
  belongs_to :town
  belongs_to :road
end