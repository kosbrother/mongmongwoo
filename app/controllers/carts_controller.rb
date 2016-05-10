class CartsController < ApplicationController
  layout 'cart'
  def show
    @items = CartItem.includes(:item, :item_spec).where(cart_id: session[:cart_id])

  end

end
