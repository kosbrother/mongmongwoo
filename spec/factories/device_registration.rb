FactoryGirl.define do
  factory :device_registration, class: DeviceRegistration do
    registration_id Faker::Lorem.characters
  end
end