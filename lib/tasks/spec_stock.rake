namespace :specs do

  def set_all_specs_recommend_stock_num_to_zero(item)
    ItemSpec.where(item_id: item.id).update_all(recommend_stock_num: 0)
  end

  def on_shelf_days(item)
    (Time.current - item.created_at).to_i / (24*60*60).to_f
  end

  def set_alert_and_recommend_num(item)
    item.specs.on_shelf.each do |spec|
      start_sell_day = spec_start_sell_day(spec,item)
      end_sell_day = spec_end_sell_day(spec)
      sell_days = (end_sell_day - start_sell_day) / (24*60*60).to_f
      alert_num = (spec.sales_between(start_sell_day..end_sell_day) / sell_days * 7).floor
      recommend_num = (spec.sales_between(start_sell_day..end_sell_day) / sell_days * 30).floor
      spec.update_attribute(:alert_stock_num, alert_num)
      spec.update_attribute(:recommend_stock_num, recommend_num.ceil)
    end
  end

  def spec_start_sell_day(spec,item)
    item_sell_day = item.created_at
    spec_lastest_import =  AdminCartItem.joins(:admin_cart).where(item_spec: spec, admin_carts: {status: AdminCart::STATUS[:stock]}).last
    return item_sell_day if spec_lastest_import.blank?
    spec_lastest_import_day = spec_lastest_import.admin_cart.confirmed_on
    (item_sell_day > spec_lastest_import_day) ? item_sell_day : spec_lastest_import_day
  end

  def spec_end_sell_day(spec)
    stock_spec = StockSpec.find_by(item_spec: spec)
    last_order_item = OrderItem.where(item_spec: spec).last
    if stock_spec.blank? || last_order_item.blank? || stock_spec.amount > 0
      Time.current
    else
      OrderItem.where(item_spec: spec).last.created_at
    end
  end

  def median(ary)
    mid = ary.length / 2
    sorted = ary.sort
    ary.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1])
  end

  def calculate_stock(item, day = 0)
    specs_size = item.specs.on_shelf.size
    sales = item.sales_within_30_days.m_sales_amount
    case day
    when 30
      if (sales > specs_size * 2)
        set_alert_and_recommend_num(item)
      else
        set_all_specs_recommend_stock_num_to_zero(item)
      end
    when 10
      if (sales > specs_size * 0.5)
        set_alert_and_recommend_num(item)
      else
        set_all_specs_recommend_stock_num_to_zero(item)
      end
    when 5
      if (sales > 0)
        set_alert_and_recommend_num(item)
      else
        set_all_specs_recommend_stock_num_to_zero(item)
      end
    when 0
      set_alert_and_recommend_num(item)
    end
  end

  # 建議補貨水位recommend_stock_num : 補到這個水位才夠賣　= 樣式賣的量／（賣的天數) * 30
  # 警示水位alert_stock_num : 這個水位再不補，就會出現缺貨 = 樣式賣的量／（賣的天數) * 7

  # 賣的天數：　起賣日：(最後補貨日,商品上架日)取日子比較接近今日的
  #           最後賣出日： 如果貨賣完，取最後賣出貨當天，如果還沒賣完，取今天

  # if 上架過
  #   if 上架超過30天
  #     1. 決定是否繼續賣(30天賣量 > 上架樣式數 * 2 就繼續賣，否則recommend_stock_num: 0)
  #     2. 繼續賣,　計算補貨水位，警示水位
  #   elsif 上架超過10天
  #     1. 決定是否繼續賣(30天賣量 > 上架樣式數 * 0.5 就繼續賣，否則recommend_stock_num: 0)
  #     2. 繼續賣,　計算補貨水位，警示水位
  #   elsif 上架超過 5天
  #     1. 決定是否繼續賣(30天賣量 > 0 就繼續賣，否則recommend_stock_num: 0)
  #     2. 繼續賣,　計算補貨水位，警示水位
  #   else(即未滿5天)
  #     １. 繼續賣,　計算補貨水位，警示水位
  #   end
  # else
  #   recommend_stock_num: 5
  # end

  task :stock_recommend_num  => :environment do
    Item.on_shelf.find_each do |item|
      if item.ever_on_shelf
        if on_shelf_days(item) > 30
          calculate_stock(item,30)
        elsif on_shelf_days(item) > 10
          calculate_stock(item,10)
        elsif on_shelf_days(item) > 5
          calculate_stock(item,5)
        else
          calculate_stock(item)
        end
      else
        item.specs.on_shelf.update_all(recommend_stock_num: 5)
      end
      item.specs.on_shelf.where(is_stop_recommend: true).update_all(recommend_stock_num: 0)
      item.specs.on_shelf.where(is_stop_recommend: true).update_all(alert_stock_num: 0)
      item.specs.off_shelf.where("recommend_stock_num != 0").update_all(recommend_stock_num: 0)
    end
    
    Item.off_shelf.find_each do |item|
      item.specs.update_all(recommend_stock_num: 0)
    end
  end

  task :set_off_shelf_if_empty_and_stop_replenish  => :environment do
    ItemSpec.where(status: ItemSpec.statuses["on_shelf"], is_stop_recommend: true).each do |s|
      if s.stock_spec.nil? or s.stock_spec.amount == 0
        s.update_attribute(:status, ItemSpec.statuses["off_shelf"])
      end
    end
  end
end
