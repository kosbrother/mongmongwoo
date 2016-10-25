class DiscountRecordCreator
  def self.create_by_type_if_applicable(object)
    case object.class.name
    when "OrderItem"
      campaign_rule = object.item.campaign_rule
      if campaign_rule.present? && CampaignRule::PERCENTAGE_OFF_TYPE.include?(campaign_rule.discount_type) && campaign_rule.exceed_threshold?(quantity: object.item_quantity)
        DiscountRecord.create(campaign_rule_id: campaign_rule.id, discountable: object)
      end
    when "Order"
      campaigns = Campaign.money_off
      campaigns.each do |campaign|
        if campaign.campaign_rule.exceed_threshold?(amount: object.items_price)
          DiscountRecord.create(campaign_rule_id: campaign.campaign_rule_id, discountable: object)
        end
      end
    end
  end
end