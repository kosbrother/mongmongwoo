class ShoppingPoint < ActiveRecord::Base
  enum point_types: { "退貨金" => 0, "活動購物金" => 1 }

  after_create :create_record

  belongs_to :user
  belongs_to :shopping_point_campaign
  has_many :shopping_point_records

  scope :available, ->{where('valid_until > :today OR valid_until IS NULL', today: Time.current)}

  private

  def create_record
    shopping_point_records.create(amount: amount, balance: amount)
  end
end