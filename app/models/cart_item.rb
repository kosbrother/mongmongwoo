class CartItem < ActiveRecord::Base

  belongs_to :cart
  belongs_to :item
  belongs_to :item_spec

  MAX_QUANTITY = 99
  MIN_QUANTITY = 1

  def increment_quantity(quantity=1)
    update_attribute(:item_quantity, item_quantity + quantity) if item_quantity < MAX_QUANTITY
  end

  def decrement_quantity
    if item_quantity > MIN_QUANTITY
      update_attribute(:item_quantity, item_quantity - 1)
    else
      self.destroy
    end
  end

  def subtotal
    item_quantity *  (item.special_price || item.price)
  end
end
