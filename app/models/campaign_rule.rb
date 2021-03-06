class CampaignRule< ActiveRecord::Base
  include AndroidApp

  enum discount_type: {money_off: 0, percentage_off: 1, percentage_off_next:2, shopping_point: 3}
  enum rule_type: {exceed_amount: 0, exceed_quantity: 1}

  PERCENTAGE_OFF_TYPE = ["percentage_off", "percentage_off_next"]
  DISCOUNT_MONEY_TYPE = ["money_off", "shopping_point"]

  has_many :campaigns, dependent: :destroy
  has_many :items, through: :campaigns, source: :discountable, source_type: "Item"
  has_one :shopping_point_campaign, dependent: :destroy

  accepts_nested_attributes_for :shopping_point_campaign

  scope :valid, ->{ where(is_valid: true)}

  mount_uploader :banner_cover, OriginalPicUploader
  mount_uploader :card_icon, OriginalPicUploader
  mount_uploader :list_icon, OriginalPicUploader

  acts_as_paranoid

  def exceed_threshold?(options={})
    if rule_type == "exceed_amount"
      options[:amount] >= threshold
    elsif rule_type == "exceed_quantity"
      options[:quantity] >= threshold
    end
  end

  def left_to_apply(options={})
    if rule_type == "exceed_amount"
      options[:amount] < threshold ? threshold - options[:amount] : 0
    elsif rule_type == "exceed_quantity"
      options[:quantity] < threshold ? threshold - options[:quantity] : 0
    end
  end

  def able_path
    case discount_type
    when "shopping_point"
      shopping_point_campaigns_path
    else
      campaign_rule_path(self)
    end
  end
end