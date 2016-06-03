class Road < ActiveRecord::Base
  scope :select_api_fields, -> { select(:id, :name) }

  belongs_to :town
  has_many :stores
end