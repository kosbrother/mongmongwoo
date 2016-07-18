class Town < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :name) }

  OPTIONS = Town.where(county_id: County::TAIPEI_ID).pluck(:name, :id)
  
  belongs_to :county
  has_many :roads
  has_many :stores
end