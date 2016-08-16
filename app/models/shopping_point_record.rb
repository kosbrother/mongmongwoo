class ShoppingPointRecord < ActiveRecord::Base
  belongs_to :shopping_point
  belongs_to :order
end