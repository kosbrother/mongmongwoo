class NotifyToBuyWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wish_list_id)
    @wish_list = WishList.find(wish_list_id)
    @schedule = @wish_list.notify_to_buy_schedule
    if @wish_list.item_spec.stock_spec.amount > 0
      UserNotifyService.new(@wish_list.user).notify_user_to_buy(@wish_list)
      puts "Notify to buy schedule completed"
    end
    @schedule.update_attribute(:is_execute, true)
  end
end