FactoryGirl.define do
  factory :shopping_point_campaign, class: ShoppingPointCampaign do
    description Faker::Lorem.paragraph
    amount 100
    valid_until Time.current.to_date.next_month(1)
  end
end
