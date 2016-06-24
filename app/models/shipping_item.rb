class ShippingItem <ActiveRecord::Base
  belongs_to :item
  belongs_to :item_spec
  belongs_to :admin_cart
end