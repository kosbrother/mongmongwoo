class ShoppingPointRecord < ActiveRecord::Base
  belongs_to :shopping_point
  belongs_to :order

  scope :spent, -> { where('shopping_point_records.amount < 0') }

  def title
    shopping_point.shopping_point_campaign.title
  end
end