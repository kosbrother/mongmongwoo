FactoryGirl.define do
  factory :category, class: Category do
    name Faker::Book.genre
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'category.jpg')) }
  end
end