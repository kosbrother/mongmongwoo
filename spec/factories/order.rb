FactoryGirl.define do
  factory :order, class: Order do
    user
    uid '123456789'
    items_price Faker::Commerce.price
    total Faker::Commerce.price
    ship_fee Faker::Commerce.price
  end
end