FactoryGirl.define do
  factory :order, class: Order do
    user
    info
    factory :order_with_items do
      transient do
        items_count 3
      end

      after(:create) do |order, evaluator|
        FactoryGirl.create_list(:item, evaluator.items_count, :order => order)
      end
    end
  end

end