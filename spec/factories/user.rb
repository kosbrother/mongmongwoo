FactoryGirl.define do
  factory :user, class: User do
    user_name { Faker::Internet.user_name }
    uid { Faker::Number.number(10) }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    factory :user_with_registration_device do
      after (:create) do |user|
        FactoryGirl.create(:device_registration, :user => user)
      end
    end
  end

  factory :anonymous_user, class: User do
    id { User::ANONYMOUS }
    user_name { "匿名購買" }
    uid { 9999 }
    email { "anonymous@mmwooo.fake.com" }
    password { Faker::Internet.password }
  end
end
