class Cart < ActiveRecord::Base
  include CalculatePrice

  has_many :cart_items, dependent: :destroy
  has_one :cart_info, dependent: :destroy
  belongs_to :user

  STEP = { checkout: 1, info: 2, confirm: 3}
  FREE_SHIPPING_PRICE = 490
  SHIP_FEE = 90

  def m_items
    cart_items
  end
end
