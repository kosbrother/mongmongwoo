module CartItemHelper
  def cart_item_current_price(origin_price, discounted_price)
    if discounted_price < origin_price
      content_tag(:div, price_with_unit(origin_price), class: "-delete") +
      content_tag(:div, price_with_unit(discounted_price), class: "cheaper-price")
    else
      price_with_unit(origin_price)
    end
  end
end