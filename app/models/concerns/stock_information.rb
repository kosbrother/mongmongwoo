module StockInformation
  extend ActiveSupport::Concern

  def stock_item_quantity
    stock_items = StockSpec.where(item_spec_id: item_spec_id)
    stock_items.map(&:amount).inject(:+) || 0
  end
end