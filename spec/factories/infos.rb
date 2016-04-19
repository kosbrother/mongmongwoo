
FactoryGirl.define do
  factory :info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_address Faker::Address.street_address
  end
end