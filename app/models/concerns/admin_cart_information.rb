module AdminCartInformation
  extend ActiveSupport::Concern
  class NoSpecIdDefinedError < StandardError; end

  def shipping_item_quantity
    items = AdminCartItem.shipping_status.where(item_spec_id: spec_id)
    items.map(&:item_quantity).inject(:+) || 0
  end

  def stock_item_quantity
    stocks = StockSpec.where(item_spec_id: spec_id)
    stocks.map(&:amount).inject(:+) || 0
  end

  def spec_id
    raise AdminCartInformation::NoSpecIdDefinedError
  end
end