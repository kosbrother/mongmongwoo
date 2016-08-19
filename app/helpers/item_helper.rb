module ItemHelper
  def render_favorite_btn(item, status)
    type = status ? "un-favorite" : "favorite"
    class_name =  status ? "checked" : "uncheck"
    link_to '加入收藏',  favorite_favorite_item_path(item, type: type ), id: 'add-favorite', class: "add -wishlist #{class_name} ", remote: true
  end

  def render_add_to_cart_btn(item)
    if item.status == "on_shelf"
      submit_tag "加入購物車", class: "add", onClick: analytic_event("product", "add_to_cart", item.name)
    else
      submit_tag "商品已下架", class: "add -forbidden", disabled: "disabled"
    end
  end

  def render_item_status_block(status)
    content_tag(:div, t(status), class: status == "on_shelf" ? 'block' :  'block -off-shelf')
  end

  def side_item_current_price(item)
    if item.special_price
      content_tag(:div, "優惠價#{price_with_unit(item.price)}", class: "special -delete") +
      content_tag(:div, price_with_unit(item.special_price), class: "price")
    else
      content_tag(:div, "-優惠價-", class: "special") +
      content_tag(:div, price_with_unit(item.price), class: "price")
    end
  end

  def list_item_current_price(item)
    if item.special_price
      content_tag(:span, "優惠價#{price_with_unit(item.price)}", class: "special -delete") +
      content_tag(:span, price_with_unit(item.special_price))
    else
      content_tag(:span, "-優惠價-", class: "special") +
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
     stock_amount > 10 ? '庫存充足' : stock_amount
  end
end
