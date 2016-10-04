class CampaignRule< ActiveRecord::Base
  enum discount_type: {money_off: 0, percentage_off: 1, percentage_off_next:2, shopping_point: 3}
  enum rule_type: {exceed_amount: 0, exceed_quantity: 1}

  PERCENTAGE_OFF_TYPE = ["percentage_off", "percentage_off_next"]

  has_many :campaigns, dependent: :destroy

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

  def apply_discount(options={})
    if discount_type == 'money_off'
      options[:amount] - discount_money
    elsif discount_type == 'percentage_off'
      (options[:amount] * discount_percentage).round
    elsif discount_type == 'percentage_off_next'
      unit_price= options[:amount]/options[:quantity]
      total = unit_price + (options[:quantity]-1)*discount_percentage*unit_price
      total.round
    end
  end
end