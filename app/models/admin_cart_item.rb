class AdminCartItem < ActiveRecord::Base
  include AdminCartInformation
  
  scope :shipping_status, -> { joins(:admin_cart).where(admin_carts: { status: AdminCart::STATUS[:shipping] }) }
  scope :by_cart, -> { includes(:admin_cart) }

  belongs_to :admin_cart
  belongs_to :item
  belongs_to :item_spec
  
  validates_presence_of :admin_cart_id, :item_id, :item_spec_id

  def spec_id
    item_spec_id
  end

  def add_item_quantity(quantity)
    update_column(:item_quantity, item_quantity + quantity.to_i)
  end
end