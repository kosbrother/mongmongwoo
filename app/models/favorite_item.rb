class FavoriteItem < ActiveRecord::Base
  include Scheduleable

  enum favorite_type: { "my_favorite" => 0, "wish_list" => 1 }
  enum schedule_type: { notify_user_to_buy: "notify_wish_list", delete_user_wish_list: "delete_wish_list" }
  default_scope { where(favorite_type:  FavoriteItem.favorite_types["my_favorite"]) }

  belongs_to :user
  belongs_to :item
  has_one :notify_wish_list_schedule, -> { where(schedule_type: "notify_wish_list") }, class_name: "Schedule", foreign_key: :scheduleable_id
  has_one :delete_wish_list_schedule, -> { where(schedule_type: "delete_wish_list") }, class_name: "Schedule", foreign_key: :scheduleable_id

  acts_as_paranoid
end
