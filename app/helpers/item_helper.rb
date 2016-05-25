module ItemHelper
  def render_favorite_btn(item, status)
    type = status ? "un-favorite" : "favorite"
    class_name =  status ? "checked" : "uncheck"
    link_to '加入收藏',  favorite_favorite_item_path(item, type: type ), id: 'add-favorite', class: "add -wishlist #{class_name} ", remote: true
  end
end
