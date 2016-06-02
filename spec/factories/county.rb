FactoryGirl.define do
  factory :seven_store_county, class: County do
    name Faker::Address.state
    store_type 4
  end

  factory :non_seven_store_county, class: County do
    name Faker::Address.state
    store_type [1, 2, 3].sample
  end
end