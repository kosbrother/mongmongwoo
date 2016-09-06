class UserFinder
  def self.find_wish_lists_users(item_spec)
    wish_lists = item_spec.wish_lists
    user_ids = wish_lists.map(&:user_id)
    users = User.where(id: user_ids)
  end
end