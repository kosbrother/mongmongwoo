class Town < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :name) }

  OPTIONS = County.seven_stores.includes(:towns).first.towns.collect{|t| [t.name, t.id]}
  
  belongs_to :county
  has_many :roads
  has_many :stores
end