
FactoryGirl.define do
  factory :user, class: User do
    user_name Faker::Internet.user_name
    uid '123456789'
    email Faker::Internet.email
  end
end
