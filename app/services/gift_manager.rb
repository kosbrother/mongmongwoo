class GiftManager
  def self.create_by_type_if_applicable(object)
    case object.class.name
    when "OrderItem"
      campaign_rule = object.item.campaign_rule
      if campaign_rule.present? && campaign_rule.discount_type == "get_one_free" && campaign_rule.exceed_threshold?(quantity: object.item_quantity)
        order_item = object.dup
        gift_quantity = object.item_quantity/campaign_rule.threshold
        order_item.item_name.insert(0, "(贈品)")
        order_item.item_quantity = gift_quantity
        order_item.item_price = 0
        order_item.save
      end
    end
  end
end