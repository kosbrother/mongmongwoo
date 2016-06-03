class Store < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :store_code, :name, :address, :phone, :lat, :lng) }

  belongs_to :county
  belongs_to :town
  belongs_to :road
end