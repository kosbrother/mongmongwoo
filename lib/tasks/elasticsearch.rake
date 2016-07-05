require 'elasticsearch/persistence'
namespace :elasticsearch do
  task :import_items => :environment do
    repository = Elasticsearch::Persistence::Repository.new
    repository.index = Item.index_name
    repository.type = 'item'
    repository.create_index! force: true
    items = Item.all.select(:id, :name, :description)
    items.each do |i|
      repository.save(i.as_indexed_json)
    end
    puts "success"
  end
end
