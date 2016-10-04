class ShoppingPointCampaign < ActiveRecord::Base
  REGISTER_ID = 1

  has_many :shopping_points
  belongs_to :campaign_rule

  scope :with_campaign_rule, ->{where.not(campaign_rule_id: nil).where(is_expired: false)}
end