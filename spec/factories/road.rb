FactoryGirl.define do
  factory :road, class: Road do
    name Faker::Address.street_name
    store_type 4
  end
end