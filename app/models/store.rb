class Store < ActiveRecord::Base
  SEVEN_STORE_TYPE = 4
  acts_as_paranoid

  scope :select_api_fields, -> { select(:id, :store_code, :name, :address, :phone, :lat, :lng) }
  scope :seven_stores, -> { where("store_type = ?", Store::SEVEN_STORE_TYPE) }
  scope :by_store_code_or_name, -> (store_code, store_name) { where('store_code = ? OR name = ?', store_code, store_name) }

  belongs_to :county
  belongs_to :town
  belongs_to :road

  validates_uniqueness_of :store_code

  geocoded_by :address, :latitude => :lat, :longitude => :lng
  after_validation :geocode
end