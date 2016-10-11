class ShoppingPointRecord < ActiveRecord::Base
  belongs_to :shopping_point
  belongs_to :order

  def title
    shopping_point.shopping_point_campaign.title
  end
end