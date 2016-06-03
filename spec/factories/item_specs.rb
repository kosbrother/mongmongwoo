FactoryGirl.define do
  factory :item_spec, class: ItemSpec do
    style Faker::Commerce.product_name
    style_pic { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'style_pic.png')) }
  end
end