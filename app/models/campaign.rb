class Campaign < ActiveRecord::Base
  belongs_to :campaign_rule
  belongs_to :discountable, polymorphic: true

  scope :money_off, ->{joins(:campaign_rule).where(discountable: nil, campaign_rules: { discount_type: CampaignRule.discount_types["money_off"], is_valid: true })}
end