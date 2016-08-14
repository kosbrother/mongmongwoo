module Admin::OrderItemsHelper
  def unable_to_buy_status(order_item)
    statuses = []
    statuses << '商品已下架' unless order_item.item_on_shelf?
    statuses << '樣式已下架' unless order_item.item_spec_on_shelf?
    statuses << '庫存不足' unless order_item.stock_amount_enough?
    statuses.join('，')
  end

end