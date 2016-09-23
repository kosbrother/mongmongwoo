module Admin::ShoppingPointsHelper
  def shopping_point_type(shopping_point)
    if shopping_point.point_type == "退貨金"
      shopping_point_record = ShoppingPointRecord.find_by(shopping_point_id: shopping_point.id)
      "#{shopping_point.point_type}(單號：#{shopping_point_record.order_id})"
    elsif shopping_point.point_type == "活動購物金"
      "#{shopping_point.point_type}(標題：#{shopping_point.shopping_point_campaign.title})"
    else
      shopping_point.point_type
    end
  end
end