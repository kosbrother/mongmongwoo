FactoryGirl.define do
  factory :official_message, class: Message do
    title Faker::Company.buzzword
    content Faker::Lorem.paragraph
    message_type "0"
  end

  factory :personal_message, class: Message do
    title Faker::Company.buzzword
    content Faker::Lorem.paragraph
    message_type "1"
  end
end