class FavoriteItem < ActiveRecord::Base
  enum favorite_type: { "my_favorite" => 0, "wish_list" => 1 }
  default_scope { where(favorite_type:  FavoriteItem.favorite_types["my_favorite"]) }

  belongs_to :user
  belongs_to :item

  acts_as_paranoid
end
