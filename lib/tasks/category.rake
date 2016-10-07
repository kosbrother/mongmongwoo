namespace :categories do
  task :create_recent_5_months_subcategory => :environment do
    the_new_category = Category.find(Category::NEW_ID)
    recent_5_months = []
    5.times { |index| recent_5_months << (Time.current.month - index) }
    the_new_category.items.on_shelf.order(created_at: :asc).each do |item|
      if recent_5_months.include?(item.created_at.month)
        item.set_new_on_shelf_categories
      end
    end
  end

  task :delete_subcategory_if_excluded_recent_5_months => :environment do
    the_new_category = Category.find(Category::NEW_ID)
    recent_5_months_subcategory_ids = []
    5.times do |index|
      subcategory = the_new_category.child_categories.find_by(name: "#{Time.current.year}年#{Time.current.month - index}月")
      recent_5_months_subcategory_ids << subcategory.id if subcategory
    end
    the_new_category.child_categories.where.not(id: recent_5_months_subcategory_ids).destroy_all
  end
end