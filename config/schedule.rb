# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 3.hours do
  rake 'items:item_position',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
  rake 'specs:stock_recommend_num',:output => {:error => 'log/error.log', :standard => 'log/cron.log'}
  rake 'specs:stock_recommend_email', :output => {:error => 'log/error.log', :standard => 'log/cron.log'}
end