FactoryGirl.define do
  factory :refund_point, class: ShoppingPoint do
    point_type ShoppingPoint.point_types["退貨金"]
    amount 50
    valid_until Time.current.to_date.next_month(1)
  end

  factory :campaign_point, class: ShoppingPoint do
    point_type ShoppingPoint.point_types["活動購物金"]
    valid_until Time.current.to_date.next_month(1)
  end
end