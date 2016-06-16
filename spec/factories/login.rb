FactoryGirl.define do
  factory :login, class: Login do
    uid { Faker::Number.number(10) }
    user_name { Faker::Internet.user_name }
    gender 'female'

    trait :facebook do
      provider 'facebook'
    end
  end
end
