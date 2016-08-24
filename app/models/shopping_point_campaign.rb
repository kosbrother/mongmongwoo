class ShoppingPointCampaign < ActiveRecord::Base
  REGISTER_ID = 1

  has_many :shopping_points
end