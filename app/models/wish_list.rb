class WishList < FavoriteItem
  default_scope { where(favorite_type:  FavoriteItem.favorite_types["wish_list"]) }

  belongs_to :item_spec
end