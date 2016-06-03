FactoryGirl.define do
  factory :town, class: Town do
    name Faker::Address.city
    store_type 4
  end
end