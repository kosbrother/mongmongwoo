namespace :specs do

  task :stock_recommend_num  => :environment do
    Item.find_each do |item|
      if(item.created_at < Time.now - 10.days)
        m_sales_amount = item.sales_within_30_days.m_sales_amount
        if m_sales_amount == 0
          item.specs.each{|s| s.update_attribute(:recommend_stock_num,0)}
        else
          specs_sales = []
          item.specs.on_shelf.each {|spec| specs_sales << OrderItem.product_style_sales(spec.item_id, spec.id).sum_item_quantity}
          ratio = specs_sales.collect{|s| s/(specs_sales.sum.to_f)}
          stock_num = ratio.collect{|r| (r*m_sales_amount).ceil}
          item.specs.on_shelf.each_with_index{|s,i| s.update_attribute(:recommend_stock_num,stock_num[i])}
          item.specs.off_shelf.each{|s| s.update_attribute(:recommend_stock_num,0)}
        end
      end
    end
  end
end
