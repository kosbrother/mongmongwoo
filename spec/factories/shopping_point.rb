FactoryGirl.define do
  factory :income_point, class: ShoppingPoint do
    point_type ShoppingPoint.point_types["退訂入帳"]
    amount 50
    valid_until Date.today.next_month(1)
  end

  factory :spend_point, class: ShoppingPoint do
    point_type ShoppingPoint.point_types["消費支出"]
    amount -50
  end

  factory :gift_point, class: ShoppingPoint do
    point_type ShoppingPoint.point_types["贈金入帳"]
    amount 50
    valid_until Date.today.next_month(1)
  end
end