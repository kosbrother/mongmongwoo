namespace :wish_lists do
  task :clear_wish_list_by_check_holding_days => :environment do
    WishList.all.find_each do |wish_list|
      holding_days = (Time.current.midnight - wish_list.created_at.midnight).round / 1.day
      item_spec = wish_list.item_spec
      stock_spec = StockSpec.find_or_create_by(item_spec_id: item_spec.id, item_id: item_spec.item_id)

      if holding_days == 30 && stock_spec.amount > 0
        UserNotifyService.new(wish_list.user).notify_item_spec_arrival(wish_list)
        wish_list.destroy
      elsif holding_days == 45
        wish_list.destroy
      end
    end
  end
end