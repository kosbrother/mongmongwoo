class CampaignRule< ActiveRecord::Base
  enum discount_type: {money_off: 0, percentage_off: 1, percentage_off_next:2, shopping_point: 3}
  enum rule_type: {exceed_amount: 0, exceed_quantity: 1}

  PERCENTAGE_OFF_TYPE = ["percentage_off", "percentage_off_next"]

  has_many :campaigns, dependent: :destroy

  scope :valid, ->{ where(is_valid: true)}

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
end