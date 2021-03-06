class ShoppingPoint < ActiveRecord::Base
  enum point_type: { "退貨金" => 0, "活動購物金" => 1, "送購物金" => 2 }

  after_create :create_record
  after_update :set_not_valid_if_amount_zero, :set_valid_if_amount_greater_than_zero_and_not_valid

  belongs_to :user
  belongs_to :shopping_point_campaign, -> { with_deleted}
  has_many :shopping_point_records

  scope :valid, ->{where(is_valid: true)}
  scope :recent, ->{order(id: :desc)}

  def description
    shopping_point_campaign.description if shopping_point_campaign_id
  end

  private

  def create_record
    shopping_point_records.create(amount: amount, balance: amount)
  end

  def set_not_valid_if_amount_zero
    update_column(:is_valid, false) if amount == 0
  end

  def set_valid_if_amount_greater_than_zero_and_not_valid
    update_column(:is_valid, true) if amount > 0 && is_valid == false
  end
end