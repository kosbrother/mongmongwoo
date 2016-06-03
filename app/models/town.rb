class Town < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :id_and_name, -> { select(:id, :name) }
  
  belongs_to :county
  has_many :roads
  has_many :stores
end