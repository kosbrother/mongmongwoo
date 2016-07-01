FactoryGirl.define do
  factory :item_spec, class: ItemSpec do
    style Faker::Commerce.product_name
    style_pic { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'style_pic.png')) }
  end
  factory :off_shelf_item_spec, class: ItemSpec do
    status ItemSpec.statuses["off_shelf"]
    style Faker::Commerce.product_name
    style_pic { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'style_pic.png')) }
  end
end