module AdminCartInformation
  extend ActiveSupport::Concern

  def shipping_item_quantity
    items = AdminCartItem.shipping_status.where(item_spec_id: spec_id)
    items.map(&:actual_item_quantity).inject(:+) || 0
  end

  def stock_item_quantity
    stock = StockSpec.find_by(item_spec_id: spec_id)
    stock ? stock.amount : 0
  end

  def spec_id
    raise NotImplementedError
  end
end