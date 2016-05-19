class Cart < ActiveRecord::Base

  has_many :cart_items, dependent: :destroy
  has_one :cart_info, dependent: :destroy
  belongs_to :user

  STEP = { checkout: 1, info: 2, confirm: 3}
  FREE_SHIPPING_PRICE = 490
  SHIP_FEE = 60


end
