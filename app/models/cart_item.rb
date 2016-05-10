class CartItem < ActiveRecord::Base

  belongs_to :cart
  belongs_to :item
  belongs_to :item_spec

  def increment_quantity
    update_attribute(:item_quantity, item_quantity + 1) if item_quantity < 99
  end

  def decrement_quantity
    if item_quantity > 1
      update_attribute(:item_quantity, item_quantity - 1)
    else
      self.destroy
    end
  end

  def subtotal
    item_quantity *  item.price
  end

end
