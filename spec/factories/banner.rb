FactoryGirl.define do
  factory :banner, class: Banner do
    title Faker::Book.genre
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'category.jpg')) }
  end
end