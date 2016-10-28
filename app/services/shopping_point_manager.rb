class ShoppingPointManager
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def self.has_refund_shopping_point?(order)
    order.shopping_point_records.exists?(['amount > :amount', amount: 0])
  end

  def self.create_register_shopping_point(user_id)
    campaign = ShoppingPointCampaign.find(ShoppingPointCampaign::REGISTER_ID)
    ShoppingPoint.create(user_id: user_id, point_type: ShoppingPoint.point_types["活動購物金"], amount: campaign.amount, shopping_point_campaign_id: campaign.id)
  end

  def self.find_refund_record(shopping_point)
    shopping_point.shopping_point_records.where('amount > :amount', amount: 0).first
  end

  def self.refund_spent_shoppong_point(order)
    spent_records = order.shopping_point_records.spent

    if spent_records.exists?
      ActiveRecord::Base.transaction do
        spent_records.each do |shopping_point_record|
          shopping_point_record.shopping_point.amount += shopping_point_record.amount.abs
          shopping_point_record.shopping_point.save
          shopping_point_record.shopping_point.shopping_point_records.delete(shopping_point_record.id)
        end
      end
    end
  end

  def total_amount
    ShoppingPoint.valid.where(user_id: user.id).sum(:amount)
  end

  def calculate_available_shopping_point(items_price)
    if user.is_login? && items_price >= 400
      [total_amount, items_price].min
    else
      0
    end
  end

  def able_to_refund_shopping_point_orders
    user.orders.status(Order.statuses["退貨"]).select{|order| ShoppingPointManager.has_refund_shopping_point?(order) == false}
  end

  def create_shopping_point_if_applicable(order)
    if user.is_login?
      ShoppingPointCampaign.with_campaign_rule.each do |shopping_point_campaign|
        spend_shopping_point_amount = order.shopping_point_records.spent.sum(:amount).abs
        reduced_items_price = order.items_price - spend_shopping_point_amount
        if shopping_point_campaign.campaign_rule.exceed_threshold?(amount: reduced_items_price)
          shopping_point = user.shopping_points.create(point_type: ShoppingPoint.point_types["活動購物金"], amount: shopping_point_campaign.amount, shopping_point_campaign_id: shopping_point_campaign.id)
          shopping_point.shopping_point_records.first.update_column(:order_id, order.id)
        end
      end
    end
  end

  def spend_shopping_points(order, spend_amount)
    return if spend_amount <= 0
    shopping_points = user.shopping_points.valid
    shopping_points.each do |shopping_point|
      if spend_amount > shopping_point.amount
        spend_amount -= shopping_point.amount
        reduce_shopping_point_and_save_record(shopping_point, shopping_point.amount, order.id)
      else
        reduce_shopping_point_and_save_record(shopping_point, spend_amount, order.id)
        break
      end
    end
  end

  private

  def reduce_shopping_point_and_save_record(shopping_point, reduce_amount, order_id)
    shopping_point.amount -= reduce_amount
    shopping_point.save
    shopping_point.shopping_point_records.create(order_id: order_id, amount: -reduce_amount, balance: shopping_point.amount)
  end
end
