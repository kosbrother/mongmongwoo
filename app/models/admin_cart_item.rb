class AdminCartItem < ActiveRecord::Base
  include StockInformation
  
  scope :shipping_status, -> { joins(:admin_cart).where(admin_carts: { status: AdminCart::STATUS[:shipping] }) }
  scope :by_cart, -> { includes(:admin_cart) }

  belongs_to :admin_cart
  belongs_to :item
  belongs_to :item_spec

  def shipping_item_quantity
    items = AdminCartItem.shipping_status.where(item_spec_id: item_spec_id)
    items.map(&:item_quantity).inject(:+) || 0
  end
end