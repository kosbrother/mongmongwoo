class Road < ActiveRecord::Base
  scope :seven_stores, -> { where("store_type = ?", "4") }
  scope :id_and_name, -> { select(:id, :name) }

  belongs_to :town
  has_many :stores
end