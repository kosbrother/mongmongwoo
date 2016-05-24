module ItemHelper
  def render_favorite_btn(status)
    link_to '加入收藏', '', id: 'add-favorite' , class: "add -wishlist #{ status ? "checked" : "uncheck"} ", remote: true, 'data-id': @item.id
  end

  def transfer_item_status(status)
    case status
      when 'on_shelf'
        '已上架'
      when 'off_shelf'
        '已下架'
    end
  end
end
