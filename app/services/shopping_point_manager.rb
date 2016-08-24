class ShoppingPointManager
  def self.create_refund_shopping_point(order)
    amount = order.items_price
    user_id = order.user_id
    shopping_point = ShoppingPoint.create(user_id: user_id, point_type: ShoppingPoint.point_types["退貨金"], amount: amount)
    shopping_point.shopping_point_records.first.update_column(:order_id, order.id)
  end

  def self.spend_shopping_points(order, spend_amount)
    user = order.user
    shopping_points = user.shopping_points.valid
    ActiveRecord::Base.transaction do
      shopping_points.each do |shopping_point|
        if spend_amount > shopping_point.amount
          spend_amount -= shopping_point.amount
          reduce_shopping_point(shopping_point, shopping_point.amount, order.id)
        else
          reduce_shopping_point(shopping_point, spend_amount, order.id)
          break
        end
      end
    end
  end

  def self.has_refund_shopping_point?(order)
    order.shopping_point_records.any?{|record| record.amount > 0}
  end

  def self.create_register_shopping_point(user_id)
    campaign = ShoppingPointCampaign.find(ShoppingPointCampaign::REGISTER_ID)
    ShoppingPoint.create(user_id: user_id, point_type: ShoppingPoint.point_types["活動購物金"], amount: campaign.amount, shopping_point_campaign_id: campaign.id)
  end

  private

  def self.reduce_shopping_point(shopping_point, reduce_amount, order_id)
    shopping_point.amount -= reduce_amount
    shopping_point.save
    shopping_point.shopping_point_records.create(order_id: order_id, amount: -reduce_amount, balance: shopping_point.amount)
  end
end
