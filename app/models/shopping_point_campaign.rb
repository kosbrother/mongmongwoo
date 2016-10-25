class ShoppingPointCampaign < ActiveRecord::Base
  REGISTER_ID = 1

  after_create :update_campaign_rule_date_if_has_campaign_rule

  has_many :shopping_points
  belongs_to :campaign_rule

  scope :with_campaign_rule, ->{where.not(campaign_rule_id: nil).where(is_expired: false)}

  acts_as_paranoid

  private

  def update_campaign_rule_date_if_has_campaign_rule
    if campaign_rule.present?
      campaign_rule.update_column(:valid_until, valid_until)
    end
  end
end