FactoryGirl.define do
  factory :order_info, class: OrderInfo do
    ship_name Faker::Name.name
    ship_address Faker::Address.street_address
    ship_email Faker::Internet.email
    ship_phone Faker::PhoneNumber.phone_number
    association :store, factory: :store
    before :create do |info|
      info.ship_store_code = info.store.name
      info.ship_store_name = info.store.store_code
    end

    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :set_blacklisted_by_checking_order_info) }
    after(:build) { |order_info| order_info.class.skip_callback(:save, :after, :set_is_repurchased_by_checking_order_info) }
  end
end