module CalculatePrice
  extend ActiveSupport::Concern

  def calculate_items_price
    m_items.reduce(0) do |sum, current|
      sum + current.subtotal
    end
  end

  def calculate_reduced_items_price
    calculate_items_price - reduced_price_amount
  end

  def calculate_ship_fee
    if calculate_reduced_items_price > Cart::FREE_SHIPPING_PRICE
      0
    else
      Cart::SHIP_FEE
    end
  end

  def calculate_total
    calculate_reduced_items_price + calculate_ship_fee
  end

  def m_items
    raise NotImplementedError
  end

  def reduced_price_amount
    raise NotImplementedError
  end
end