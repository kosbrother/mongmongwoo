FactoryGirl.define do
  factory :store_delivery_order_info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_email Faker::Internet.email
    ship_phone Faker::PhoneNumber.phone_number
    association :store, factory: :store
    before :create do |info|
      info.ship_store_code = info.store.name
      info.ship_store_name = info.store.store_code
    end

    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_blacklisted) }
    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_repurchased) }
  end

  factory :home_delivery_order_info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_address Faker::Address.street_address
    ship_email Faker::Internet.email
    ship_phone Faker::PhoneNumber.phone_number

    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_blacklisted) }
    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_repurchased) }
  end

  factory :home_delivery_by_credit_card_order_info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_address Faker::Address.street_address
    ship_email Faker::Internet.email
    ship_phone Faker::PhoneNumber.phone_number

    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_blacklisted) }
    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :check_repurchased) }
  end
end