module ItemHelper
  def render_favorite_btn(item)
    is_in_favorite_items = is_in_favorite_items?(item.id)
    type = is_in_favorite_items ? "un-favorite" : "favorite"
    btn_class_name = is_in_favorite_items ? "checked" : "uncheck"
    link_to '加入收藏',  toggle_favorite_favorite_item_path(item, type: type), id: 'add-favorite', class: "add -favorites #{btn_class_name} ", remote: true
  end

  def is_in_favorite_items?(item_id)
    current_user.favorite_items.exists?(item_id: item_id) if current_user
  end

  def render_off_shelf_or_add_btn(item, item_spec, option)
    hidden_class_name = "hidden" if option[:is_hidden]
    if item.status == "off_shelf"
      render_off_shelf_status(item_spec.id, hidden_class_name)
    elsif item_spec.stock_amount == 0
      render_add_wish_lists_btn(item, item_spec.id, hidden_class_name)
    else
      render_add_to_cart_btn(item, item_spec.id, hidden_class_name)
    end
  end

  def render_off_shelf_status(item_spec_id, hidden_class)
    submit_tag "商品已下架", class: "add -forbidden #{hidden_class} add-btn", disabled: "disabled", id: "add-btn-#{item_spec_id}"
  end

  def render_add_to_cart_btn(item, item_spec_id, hidden_class)
    submit_tag "加入購物車", class: "add #{hidden_class} add-btn add-to-cart-track", id: "add-btn-#{item_spec_id}", data: { item_id: item.id, item_name: item.name, item_price: item.price }
  end

  def render_add_wish_lists_btn(item, item_spec_id, hidden_class)
    is_in_wish_lists = is_in_wish_lists?(item_spec_id)
    type = is_in_wish_lists ? "un-wish" : "wish"
    btn_class_name = is_in_wish_lists ? "checked" : "uncheck"
    link_to "貨到通知我", toggle_wish_wish_list_path(item_id: item.id, item_spec_id: item_spec_id, type: type), class: "add -wishlist add-btn #{btn_class_name} #{hidden_class}", id: "add-btn-#{item_spec_id}", remote: true
  end

  def is_in_wish_lists?(item_spec_id)
    current_user.wish_lists.exists?(item_spec_id: item_spec_id) if current_user
  end

  def render_item_status_block(status)
    content_tag(:div, t(status), class: status == "on_shelf" ? 'block' :  'block -off-shelf')
  end

  def side_item_current_price(item)
    if item.special_price
      content_tag(:div, class: "special -delete", property: "offers", typeof: "Offer") do
        content_tag(:span, content_tag(:span, "原價#{price_with_unit(item.price)}", property: "price", content: "#{item.price}.00"), property: "priceCurrency", content: "TWD")
      end +
      content_tag(:div, class: "price", property: "offers", typeof: "Offer") do
        content_tag(:span, content_tag(:span, price_with_unit(item.special_price), property: "price", content: "#{item.special_price}.00"), property: "priceCurrency", content: "TWD")
      end
    else
      content_tag(:div, "", class: "special -delete") +
      content_tag(:div, class: "price", property: "offers", typeof: "Offer") do
        content_tag(:span, content_tag(:span, price_with_unit(item.price), property: "price", content: "#{item.price}.00"), property: "priceCurrency", content: "TWD")
      end
    end
  end

  def list_item_current_price(item)
    if item.special_price
      content_tag(:span, content_tag(:span, price_with_unit(item.special_price), property: "lowPrice", content: "#{item.special_price}.00"), property: "priceCurrency", content: "TWD")+
      content_tag(:span, content_tag(:span, "原價#{price_with_unit(item.price)}", property: "highPrice", content: "#{item.price}.00"), class: "special -delete", property: "priceCurrency", content: "TWD")
    else
      content_tag(:span, content_tag(:span, price_with_unit(item.price), property: "price", content: "#{item.price}.00"), property: "priceCurrency", content: "TWD")
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

  def render_item_spec_icon(item_spec, stock_amount, options={})
    img_class_name = options[:is_active] ? 'pic active' : 'pic'
    div_class_name = ' mask' if  stock_amount == 0
    html_options = {class: img_class_name, id: "spec-#{item_spec.id}", 'data-id': item_spec.id, "data-stock-amount": stock_amount, "data-stock-status": render_stock_amount(stock_amount)}
    content_tag(:div, class: "icon #{div_class_name}") do
      image_tag(item_spec.style_pic.url, html_options)
    end
  end
end
