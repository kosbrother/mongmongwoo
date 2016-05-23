module PriceHelper
  def price_with_unit(price)
    "NT$ " + price.to_s
  end

  def ship_fee
    if @total > Cart::FREE_SHIPPING_PRICE
      0
    else
      Cart::SHIP_FEE
    end
  end
end