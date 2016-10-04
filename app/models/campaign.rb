class Campaign < ActiveRecord::Base
  belongs_to :campaign_rule
  belongs_to :discountable, polymorphic: true

  scope :percentage_off, ->(discountable=nil){joins(:campaign_rule).where(discountable: discountable, campaign_rules: { discount_type: CampaignRule::PERCENTAGE_OFF_TYPE.map{|type| CampaignRule.discount_types[type] }, is_valid: true})}
  scope :exceed_amount, ->(discountable=nil){joins(:campaign_rule).where(discountable: discountable, campaign_rules: { rule_type: CampaignRule.rule_types["exceed_amount"], is_valid: true })}
end