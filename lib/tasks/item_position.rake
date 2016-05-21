namespace :items do

  task :item_position  => :environment do

    # 最新上架 only keep 150 items
    cs = ItemCategory.where(category_id: 11).order(created_at: :desc)
    cs.each_with_index do |c,index|
      c.delete if index > 149
    end

    Category.all.each do |category|
      position_cs = []

      # select 3 items from within 7 days
      cs = ItemCategory.where(category_id: category.id).order(created_at: :desc).map(&:id)
      recent_cs = ItemCategory.where(category: category, created_at: TimeSupport.time_until('week'))
      recent_cs = recent_cs.shuffle
      (0..2).each do |i|
        next unless recent_cs[i]
        position_cs << recent_cs[i]
        cs.delete(recent_cs[i].id)
      end

      # select 20 items by item sales times
      ois = OrderItem.sort_by_sales.limit(20)
      ois.each do |oi|
        item_cs = ItemCategory.where(category_id: category.id, item_id: oi.source_item_id)
        next if item_cs.blank?
        item_c = item_cs[0]
        unless position_cs.include?(item_c)
          position_cs << item_c
          cs.delete(item_c.id)
        end
      end

      # select 30 items by item sales　amount
      ois = OrderItem.sort_by_revenue.limit(30)
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
  end
end
