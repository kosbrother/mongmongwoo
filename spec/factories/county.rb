FactoryGirl.define do
  factory :county, class: County do
    name Faker::Address.state
    store_type 4
  end
end