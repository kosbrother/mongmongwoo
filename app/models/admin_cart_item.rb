class AdminCartItem < ActiveRecord::Base
  scope :shipping_status, -> { joins(:admin_cart).where(admin_carts: { status: AdminCart::STATUS[:shipping] }) }

  belongs_to :admin_cart
  belongs_to :item
  belongs_to :item_spec
end