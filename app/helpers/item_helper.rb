module ItemHelper
  def render_favorite_btn(item)
    type = is_in_favorite_items?(item.id) ? "un-favorite" : "favorite"
    class_name = is_in_favorite_items?(item.id) ? "checked" : "uncheck"
    link_to '加入收藏',  favorite_favorite_item_path(item, type: type), id: 'add-favorite', class: "add -favorites #{class_name} ", remote: true
  end

  def is_in_favorite_items?(item_id)
    current_user.favorite_items.find_by(item_id: item_id) if current_user
  end

  def render_off_shelf_or_add_btn(item, item_spec, option)
    hidden_class = "hidden" if option[:is_hidden]
    if item.status == "off_shelf"
      render_off_shelf_status(item_spec.id, hidden_class)
    elsif item_spec.stock_amount == 0
      render_add_wish_lists_btn(item.id, item_spec.id, hidden_class)
    else
      render_add_to_cart_btn(item.name, item_spec.id, hidden_class)
    end
  end

  def render_off_shelf_status(item_spec_id, hidden_class)
    submit_tag "商品已下架", class: "add -forbidden #{hidden_class} add-btn", disabled: "disabled", id: "add-btn-#{item_spec_id}"
  end

  def render_add_to_cart_btn(item_name, item_spec_id, hidden_class)
    submit_tag "加入購物車", class: "add #{hidden_class} add-btn", id: "add-btn-#{item_spec_id}", onClick: analytic_event("product", "add_to_cart", item_name)
  end

  def render_add_wish_lists_btn(item_id, item_spec_id, hidden_class)
    type = is_in_wish_lists?(item_spec_id) ? "un-wish" : "wish"
    class_name = is_in_wish_lists?(item_spec_id) ? "checked" : "uncheck"
    link_to "貨到通知我", wish_wish_list_path(item_id: item_id, item_spec_id: item_spec_id, type: type), class: "add -wishlist add-btn #{class_name} #{hidden_class}", id: "add-btn-#{item_spec_id}", remote: true
  end

  def is_in_wish_lists?(item_spec_id)
    current_user.wish_lists.find_by(item_spec_id: item_spec_id) if current_user
  end

  def render_item_status_block(status)
    content_tag(:div, t(status), class: status == "on_shelf" ? 'block' :  'block -off-shelf')
  end

  def side_item_current_price(item)
    if item.special_price
      content_tag(:div, "原價#{price_with_unit(item.price)}", class: "special -delete") +
      content_tag(:div, price_with_unit(item.special_price), class: "price")
    else
      content_tag(:div, "", class: "special -delete") +
      content_tag(:div, price_with_unit(item.price), class: "price")
    end
  end

  def list_item_current_price(item)
    if item.special_price
      content_tag(:span, price_with_unit(item.special_price))+
      content_tag(:span, "原價#{price_with_unit(item.price)}", class: "special -delete")
    else
      content_tag(:span, price_with_unit(item.price))
    end
  end

  def detail_item_current_price(item)
    if item.special_price
      content_tag(:div, class: 'price') do
        content_tag(:span, @item.special_price) +
        content_tag(:span, price_with_unit(@item.price), class: 'origin')
      end
    else
      content_tag(:div, @item.price, class: 'price')
    end
  end

  def item_current_price(item)
    item.special_price ? price_with_unit(item.special_price) : price_with_unit(item.price)
  end

  def render_stock_amount(stock_amount)
     if stock_amount == 0
       '暫無庫存'
     elsif stock_amount > 10
       '庫存充足'
     else
       stock_amount
     end
  end

  def render_special_price_icon(item)
    if item.special_price
      content_tag(:div,'', class: "special-price-tag")
    end
  end
end
