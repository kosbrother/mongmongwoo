require 'active_support/all'
Time.zone = "Taipei"
  
every 3.hours do
  rake 'items:item_position',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

every 1.day, :at => Time.zone.parse('5:00 am').utc do
  rake "-s sitemap:refresh"
  rake 'specs:stock_recommend_num',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

case @environment
when 'production'
  every 1.day, :at => Time.zone.parse('6:00 am').utc do
    runner "AdminMailer.delay.notify_recommend_stock", :output => {:error => 'log/error.log', :standard => 'log/cron.log'}
  end
end