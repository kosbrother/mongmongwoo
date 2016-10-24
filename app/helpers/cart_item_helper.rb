module CartItemHelper
  def cart_item_current_price(origin_price, discounted_price)
    if discounted_price < origin_price
      content_tag(:div, price_with_unit(origin_price), class: "-delete") +
      content_tag(:div, price_with_unit(discounted_price), class: "cheaper-price")
    else
      price_with_unit(origin_price)
    end
  end

  def cart_item_gift_info(gift_info)
    if gift_info.present?
      "贈品：#{gift_info[:item_name]} - 數量 X #{gift_info[:quantity]}"
    end
  end
end