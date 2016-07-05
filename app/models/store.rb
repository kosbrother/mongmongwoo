class Store < ActiveRecord::Base
  acts_as_paranoid
  scope :select_api_fields, -> { select(:id, :store_code, :name, :address, :phone, :lat, :lng) }
  scope :seven_stores, -> { where("store_type = ?", "4") }

  belongs_to :county
  belongs_to :town
  belongs_to :road

  def self.search_by_store_code_or_name(store_code, store_name)
    where('store_code = ? OR name = ?', store_code, store_name)
  end
end