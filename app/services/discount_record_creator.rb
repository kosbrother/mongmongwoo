class DiscountRecordCreator
  def self.create_by_type_if_applicable(object)
    case object.class.name
    when "OrderItem"
      campaigns = Campaign.percentage_off(object.item)
      campaigns.each do |campaign|
        DiscountRecord.create(campaign_rule_id: campaign.campaign_rule_id, discountable: object) if campaign.campaign_rule.exceed_threshold?(quantity: object.item_quantity, amount: object.subtotal)
      end
    when "Order"
      campaigns = Campaign.exceed_amount
      campaigns.each do |campaign|
        DiscountRecord.create(campaign_rule_id: campaign.campaign_rule_id, discountable: object) if campaign.campaign_rule.exceed_threshold?(amount: object.items_price)
      end
    end
  end
end