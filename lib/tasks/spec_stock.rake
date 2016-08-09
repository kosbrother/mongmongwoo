namespace :specs do

  task :stock_recommend_num  => :environment do
    Item.find_each do |item|
      if(item.created_at < Time.current - 10.days)
        m_sales_amount = item.sales_within_30_days.m_sales_amount
        if m_sales_amount == 0
          item.specs.each{|s| s.update_attribute(:recommend_stock_num,0)}
        else
          specs_sales = []
          item.specs.on_shelf.each {|spec| specs_sales << spec.sales_quantity}
          sum_specs_sales = specs_sales.sum == 0 ? 1 : specs_sales.sum.to_f
          ratio = specs_sales.collect{|s| s/sum_specs_sales}
          stock_num = ratio.collect{|r| (r*m_sales_amount).ceil}
          item.specs.on_shelf.each_with_index do |s,i|
            if s.is_stop_recommend
              s.update_attribute(:recommend_stock_num,0)
            else
              s.update_attribute(:recommend_stock_num,stock_num[i])
            end
          end
          item.specs.off_shelf.each{|s| s.update_attribute(:recommend_stock_num,0)}
        end
      end
    end
  end

  task :set_off_shelf_if_empty_and_stop_replenish  => :environment do
    ItemSpec.where(status: ItemSpec.statuses["on_shelf"]).each do |s|
      if s.is_stop_recommend and (s.stock_spec.nil? or s.stock_spec.amount == 0)
        s.update_attribute(:status, ItemSpec.statuses["off_shelf"])
      end
    end
  end
end
