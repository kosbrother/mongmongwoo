FactoryGirl.define do
  factory :item, class: Item do
    name Faker::Commerce.product_name
    price Faker::Number.between(100, 1000)
    special_price Faker::Number.between(1, 99)
    description Faker::Lorem.paragraph
    cover  { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'cover.jpg')) }
    url Faker::Internet.url

    factory :item_with_specs_and_photos do
      transient do
        item_specs_count 3
        photos_count 3
      end

      after(:create) do |item, evaluator|
        FactoryGirl.create_list(:item_spec, evaluator.item_specs_count, :item => item)
        FactoryGirl.create_list(:photo, evaluator.photos_count, :item => item)
      end
    end
  end
end