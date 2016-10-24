class Campaign < ActiveRecord::Base
  include Bannerable

  belongs_to :campaign_rule
  belongs_to :discountable, polymorphic: true

  scope :money_off, ->{joins(:campaign_rule).where(discountable: nil, campaign_rules: { discount_type: CampaignRule.discount_types["money_off"], is_valid: true })}

  after_create :track_price_if_type_item

  private

  def track_price_if_type_item
    if discountable_type == 'Item'
      pr = PriceRecord.new
      pr.item = discountable
      pr.changed_at = Time.current
      pr.price = discountable.price
      pr.special_price = discountable.special_price
      pr.campaign_price = discountable.price * campaign_rule.discount_percentage
      pr.save
    end
  end
end