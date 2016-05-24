module ItemHelper
  def render_favorite_btn(status)
    link_to '加入收藏', '', id: 'add-favorite' , class: "add -wishlist #{ status ? "checked" : "uncheck"} ", remote: true, 'data-id': @item.id
  end
end
