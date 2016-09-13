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

FactoryGirl.define do
  factory :stock_spec, class: StockSpec

  after(:build) { |order_info| order_info.class.skip_callback(:save, :before, :print_changed_record_to_stock_spec_logger) }
end