class PriceManagerForCart
  include CalculatePrice

  attr_reader :cart_items, :items_price, :shopping_point_amount, :reduced_items_price, :campaigns, :total_discount_amount, :shopping_point_campaigns, :ship_fee, :ship_campaign, :total

  def initialize(cart)
    @cart_items = cart.cart_items.includes({item: :specs}, :item_spec).map do |cart_item|
      PriceManagerForCartItem.new(cart_item)
    end
    @items_price = calculate_items_price
    @shopping_point_amount = cart.shopping_point_amount
    @reduced_items_price = calculate_reduced_items_price
    @campaigns = PriceManager.get_campaigns_for_order(@reduced_items_price)
    @total_discount_amount = @campaigns.sum{|campaign| campaign[:discount_amount]}
    if cart.user_id != User::ANONYMOUS
      @shopping_point_campaigns = PriceManager.return_shopping_point_campaigns(@reduced_items_price)
    else
      @shopping_point_campaigns = []
    end
    @ship_fee = PriceManager.count_ship_fee(@reduced_items_price)
    @ship_campaign = PriceManager.get_free_ship_campaign(@reduced_items_price)
    @total = @reduced_items_price - @total_discount_amount + @ship_fee
  end

  def m_items
    cart_items
  end

  def reduced_price_amount
    shopping_point_amount
  end
end