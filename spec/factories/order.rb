FactoryGirl.define do
  factory :order, class: Order do
    user
    uid '123456789'
    items_price Faker::Commerce.price
    total Faker::Commerce.price
    ship_fee Faker::Commerce.price
    association :info, factory: :order_info
    factory :order_with_items do
      transient do
        items_count 3
      end

      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:order_item, evaluator.items_count, :order => order)
      end
    end
  end

end