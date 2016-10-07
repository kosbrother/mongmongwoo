require 'active_support/all'
Time.zone = "Taipei"

every 3.hours do
  rake 'items:item_position',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

every 1.month do
  rake 'categories:delete_subcategory_if_excluded_recent_5_months',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

every 1.day, :at => Time.zone.parse('5:00 am').utc do
  rake "-s sitemap:refresh"
  rake 'specs:stock_recommend_num',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
  rake 'specs:set_off_shelf_if_empty_and_stop_replenish',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

every 1.day, :at => Time.zone.parse('12:00 am').utc do
  rake 'shopping_points:check_valid_until',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
  rake 'shopping_point_camapaigns:check_valid_until',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

case @environment
when 'production'
  every 1.day, :at => Time.zone.parse('7:00 am').utc do
    runner "AdminMailer.delay.notify_recommend_stock", :output => {:error => 'log/error.log', :standard => 'log/cron.log'}
  end
end