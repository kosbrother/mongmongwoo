require 'elasticsearch/persistence'
namespace :elasticsearch do
  task :import_items => :environment do
    repository = Elasticsearch::Persistence::Repository.new
    repository.index = "items"
    repository.type = 'item'
    repository.create_index! force: true
    items = Item.all.select(:id, :name, :description)
    items.each do |i|
      repository.save({id: i.id, name: i.name, description: i.description})
    end
    puts "success"
  end
end
