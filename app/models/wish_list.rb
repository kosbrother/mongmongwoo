class WishList < FavoriteItem
  default_scope { where(favorite_type:  FavoriteItem.favorite_types["wish_list"]) }

  belongs_to :item_spec

  after_create :push_in_notify_and_delete_schedules

  private

  def push_in_notify_and_delete_schedules
    notify_schedule = Schedule.create(scheduleable: self, execute_time: (created_at + 30.days), schedule_type: "notify_list_item")
    notify_job_id = NotifyWishListWorker.perform_at(notify_schedule.execute_time, id)
    notify_schedule.update_attribute(:job_id, notify_job_id)
    delete_schedule = Schedule.create(scheduleable: self, execute_time: (created_at + 45.days), schedule_type: "delete_list_item")
    delete_job_id = DeleteWishListWorker.perform_at(delete_schedule.execute_time, id)
    delete_schedule.update_attribute(:job_id, delete_job_id)
  end
end