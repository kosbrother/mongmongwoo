FactoryGirl.define do
  factory :order_info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_address Faker::Address.street_address
    ship_email Faker::Internet.email
    ship_phone Faker::PhoneNumber.phone_number
    ship_store_code '1234'
    ship_store_id 1
    ship_store_name Faker::Name.name
  end
end