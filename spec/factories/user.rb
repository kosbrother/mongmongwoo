FactoryGirl.define do
  factory :user, class: User do
    user_name { Faker::Internet.user_name }
    uid { Faker::Number.number(10) }
    email { Faker::Internet.email }

    factory :user_with_registration_device do
      after (:create) do |user|
        FactoryGirl.create(:device_registration, :user => user)
      end
    end
  end
end
