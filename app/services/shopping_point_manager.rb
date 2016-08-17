class ShoppingPointManager
  def create_refund_shopping_point(order)
    amount = order.items_price
    user_id = order.user_id
    shopping_point = ShoppingPoint.create(user_id: user_id, point_type: ShoppingPoint.point_types["退貨金"], amount: amount)
    shopping_point.shopping_point_records.first.update_column(:order_id, order.id)
  end
end
