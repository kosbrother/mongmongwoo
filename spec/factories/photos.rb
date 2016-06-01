FactoryGirl.define do
  factory :photo, class: Photo do
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'image.jpg')) }
  end
end