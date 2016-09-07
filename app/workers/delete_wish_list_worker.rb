class DeleteWishListWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wish_list_id)
    @wish_list = WishList.find(wish_list_id)
    @schedule = @wish_list.delete_schedule
    @wish_list.destroy
    Rails.logger.info("Destroy wish list")
    @schedule.update_attribute(:is_execute, true)
  end
end