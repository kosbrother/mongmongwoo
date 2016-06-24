class AdminCart < ActiveRecord::Base
  has_many :admin_cart_items, -> { order(id: :desc) }
  has_many :shipping_items
  belongs_to :taobao_supplier

  def transfer_to_shipping_items
    self.admin_cart_items.select(:admin_cart_id, :item_id, :item_spec_id, :item_quantity ).each do |cart_item|
      ShippingItem.create(cart_item.as_json)
    end
  end
end
