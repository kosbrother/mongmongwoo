class Cart < ActiveRecord::Base
  include CalculatePrice

  enum ship_type: { "store_delivery": 0, "home_delivery": 1, "home_delivery_by_credit_card": 2 }

  has_many :cart_items, dependent: :destroy
  has_one :cart_info, dependent: :destroy
  belongs_to :user

  STEP = { checkout: 1, info: 2, confirm: 3, finish: 4}
  FREE_SHIPPING_PRICE = 490
  SHIP_FEE = 90
  HOME_DELIVERY_TYPES = ["home_delivery", "home_delivery_by_credit_card"]

  def m_items
    cart_items.includes(:item)
  end

  def reduced_price_amount
    shopping_point_amount
  end
end
