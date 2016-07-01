module AdminCartInformation
  extend ActiveSupport::Concern

  def shipping_item_quantity
    shipping_item = get_shipping_item

    if shipping_item
      quantity = shipping_item.item_quantity
      quantity
    else
      "無運送中商品"
    end
  end

  private

  def get_shipping_item
    if self.class == ItemSpec
      AdminCartItem.shipping_status.find_by(item_spec_id: self.id)
    elsif self.class == StockSpec
      AdminCartItem.shipping_status.find_by(item_spec_id: self.item_spec_id)
    end    
  end
end