class Store < ActiveRecord::Base
  acts_as_paranoid
  scope :select_api_fields, -> { select(:id, :store_code, :name, :address, :phone, :lat, :lng) }
  scope :seven_stores, -> { where("store_type = ?", "4") }

  belongs_to :county
  belongs_to :town
  belongs_to :road

  validates_presence_of :county_id, :town_id, :road_id, :store_code, :name, :address, :phone, :lat, :lng
  validates_uniqueness_of :store_code

  def self.search_by_store_code_or_name(store_code, store_name)
    where('store_code = ? OR name = ?', store_code, store_name)
  end
end