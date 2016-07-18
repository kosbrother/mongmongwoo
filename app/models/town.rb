class Town < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :name) }

  belongs_to :county
  has_many :roads
  has_many :stores

  def self.options
    Town.where(county_id: County::TAIPEI_CITY_ID).pluck(:name, :id)
  end
end