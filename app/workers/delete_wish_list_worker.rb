class DeleteWishListWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wish_list_id)
    @wish_list = WishList.find(wish_list_id)
    @schedule = @wish_list.delete_wish_list_schedule
    @wish_list.destroy
    puts "Delete wish list schedule completed"
    @schedule.update_attribute(:is_execute, true)
  end
end