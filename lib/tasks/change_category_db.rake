namespace :change_category_db do

  task :set_all_and_new_category  => :environment do
    Item.all.each do |item|
      item.categories << Category.find(10) rescue nil
      item.categories << Category.find(11) rescue nil
    end
  end

end
