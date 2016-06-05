FactoryGirl.define do
  factory :order_item, class: OrderItem do
    item_name Faker::Commerce.product_name
    item_price Faker::Commerce.price
    item_style Faker::Name.name
    item_spec_id 1
    item_quantity 20
  end
end