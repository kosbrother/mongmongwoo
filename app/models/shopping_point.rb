class ShoppingPoint < ActiveRecord::Base
  enum point_types: { "退貨金" => 0, "活動購物金" => 1 }

  after_create :create_record
  after_update :set_is_valid_to_false

  belongs_to :user
  belongs_to :shopping_point_campaign
  has_many :shopping_point_records

  scope :available, ->{where(is_valid: true)}

  private

  def create_record
    shopping_point_records.create(amount: amount, balance: amount)
  end

  def set_is_valid_to_false
    if amount == 0
      update_column(:is_valid, false)
    end
  end
end