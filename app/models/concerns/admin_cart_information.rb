module AdminCartInformation
  extend ActiveSupport::Concern

  def shipping_item_quantity
    items = AdminCartItem.shipping_status.where(item_spec_id: spec_id)
    items.map(&:item_quantity).inject(:+) || 0
  end

  def stock_item_quantity
    stocks = StockSpec.where(item_spec_id: spec_id)
    stocks.map(&:amount).inject(:+) || 0
  end

  def spec_id
    raise NotImplementedError
  end
end