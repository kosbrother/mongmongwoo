class DiscountRecordCreator
  def self.create_by_type_if_applicable(object)
    case object.class.name
    when "OrderItem"
      campaign_rule = object.item.campaign_rule
      if campaign_rule.present?
        DiscountRecord.create(campaign_rule_id: campaign_rule.id, discountable: object) if campaign_rule.exceed_threshold?(quantity: object.item_quantity)
      end
    when "Order"
      campaigns = Campaign.money_off
      campaigns.each do |campaign|
        DiscountRecord.create(campaign_rule_id: campaign.campaign_rule_id, discountable: object) if campaign.campaign_rule.exceed_threshold?(amount: object.items_price)
      end
    end
  end
end