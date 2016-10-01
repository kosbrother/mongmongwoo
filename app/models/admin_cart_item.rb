class AdminCartItem < ActiveRecord::Base
  include AdminCartInformation

  validates_presence_of :admin_cart_id, :item_id, :item_spec_id

  belongs_to :admin_cart
  belongs_to :item, -> { with_deleted}
  belongs_to :item_spec, -> { with_deleted}

  scope :recent, -> { order(id: :desc) }
  scope :shipping_status, -> { joins(:admin_cart).where(admin_carts: { status: AdminCart::STATUS[:shipping] }) }
  scope :by_item, -> { order(item_id: :ASC) }

  def spec_id
    item_spec_id
  end

  def add_item_quantity(quantity)
    update_column(:item_quantity, item_quantity + quantity.to_i)
  end

  def update_actual_item_quantity
    update_column(:actual_item_quantity, item_quantity)
  end
end