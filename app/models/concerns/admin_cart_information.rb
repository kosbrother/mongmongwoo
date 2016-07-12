module AdminCartInformation
  extend ActiveSupport::Concern

  def shipping_item_quantity(item_spec_id)
    items = AdminCartItem.shipping_status.where(item_spec_id: item_spec_id)
    items.map(&:item_quantity).inject(:+) || 0
  end

  def stock_item_quantity(item_spec_id)
    stocks = StockSpec.where(item_spec_id: item_spec_id)
    stocks.map(&:amount).inject(:+) || 0
  end
end