class AdminCart < ActiveRecord::Base
  has_many :admin_cart_items
end
