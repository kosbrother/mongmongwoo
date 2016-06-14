class Promotion < ActiveRecord::Base
  has_many :item_promotions
  has_many :items, through: :item_promotions
end