namespace :items do

  task :item_position  => :environment do

    # put all goods in 所有商品
    category = Category.find(Category::ALL_ID)
    Item.all.each do |i|
      category.items << i unless category.items.include?(i)
    end

    Category.all.each do |category|
      position_cs = []

      cs = ItemCategory.where(category_id: category.id).order(created_at: :desc).map(&:id)
      # each select 50 items by item sales times and revenue, within 30 days
      ois = OrderItem.sort_by_sales.created_at_within(TimeSupport.within_days(30)).limit(50) + OrderItem.sort_by_revenue.created_at_within(TimeSupport.within_days(30)).limit(50)
      ois.shuffle!
      
      ois.each do |oi|
        item_cs = ItemCategory.where(category_id: category.id, item_id: oi.source_item_id)
        next if item_cs.blank?
        item_c = item_cs[0]
        unless position_cs.include?(item_c)
          position_cs << item_c
          cs.delete(item_c.id)
        end
      end

      # select item by creadted_at
      cs_items = ItemCategory.where(category_id: category.id).order(created_at: :desc)
      cs_items.each do |item|
        unless position_cs.include?(item)
          position_cs << item
          cs.delete(item.id)
        end
      end

      # save the position
      position_cs.each_with_index do |item, index|
        item.position = index + 1
        item.save
      end
    end

    cs = ItemCategory.where(category_id: Category::NEW_ID).order('rand()')
    cs.each_with_index do |c,index|
      c.position = index + 1
      c.save
    end
  end
end
