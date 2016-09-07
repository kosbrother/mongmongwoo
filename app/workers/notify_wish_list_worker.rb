class NotifyWishListWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wish_list_id)
    @wish_list = WishList.find(wish_list_id)
    @schedule = @wish_list.notify_schedule
    if @wish_list.item_spec.stock_spec.amount > 0
      UserNotifyService.new(@wish_list.user).wish_list_item_spec_arrival(@wish_list.item_spec)
      Rails.logger.info("Sending wish list notify")
    end
    @schedule.update_attribute(:is_execute, true)
  end
end