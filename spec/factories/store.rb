FactoryGirl.define do
  factory :store, class: Store do
    store_type 4
    store_code Faker::Number.number(6)
    name Faker::Company.name
    address Faker::Address.street_address
    phone Faker::PhoneNumber.phone_number
    lat Faker::Address.latitude
    lng Faker::Address.longitude
  end
end