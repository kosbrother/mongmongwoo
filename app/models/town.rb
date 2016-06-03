class Town < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :name) }
  
  belongs_to :county
  has_many :roads
  has_many :stores
end