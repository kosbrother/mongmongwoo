class FavoriteItem < ActiveRecord::Base
  include Scheduleable

  enum favorite_type: { "my_favorite" => 0, "wish_list" => 1 }
  enum schedule_type: { notify_type: "notify_list_item", delete_type: "delete_list_item" }
  default_scope { where(favorite_type:  FavoriteItem.favorite_types["my_favorite"]) }

  belongs_to :user
  belongs_to :item
  has_one :notify_schedule, -> { where(schedule_type: "notify_list_item") }, class_name: "Schedule", foreign_key: :scheduleable_id
  has_one :delete_schedule, -> { where(schedule_type: "delete_list_item") }, class_name: "Schedule", foreign_key: :scheduleable_id

  acts_as_paranoid
end
