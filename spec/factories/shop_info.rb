FactoryGirl.define do
  factory :shop_info, class: ShopInfo do
    question {Faker::Lorem.sentence}
    answer {Faker::Lorem.paragraph}
  end
end