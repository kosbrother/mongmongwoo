module AdminCartInformation
  extend ActiveSupport::Concern

  def shipping_item_quantity
    shipping_items = get_shipping_items

    if shipping_items
      quantity = shipping_items.map(&:item_quantity).inject(:+) || 0
    end
  end

  private

  def get_shipping_items
    if self.class == ItemSpec
      AdminCartItem.shipping_status.where(item_spec_id: self.id)
    elsif self.class == StockSpec
      AdminCartItem.shipping_status.where(item_spec_id: self.item_spec_id)
    end    
  end
end