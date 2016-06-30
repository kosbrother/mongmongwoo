class AdminCartItem < ActiveRecord::Base
  scope :in_shipping_cart, -> { joins(:admin_cart).where(admin_carts: { status: AdminCart::STATUS[:shipping] }) }

  belongs_to :admin_cart
  belongs_to :item
  belongs_to :item_spec
end