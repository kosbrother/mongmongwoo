FactoryGirl.define do
  factory :order_item, class: OrderItem do
    item_name Faker::Commerce.product_name
    item_price Faker::Commerce.price
  end
end