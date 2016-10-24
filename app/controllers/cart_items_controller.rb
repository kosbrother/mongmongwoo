class CartItemsController < ApplicationController

  def create
    cart_item = current_cart.cart_items.find_or_create_by(cart_item_params)
    cart_item.increment_quantity(params[:cart_item][:item_quantity].to_i)
  end

  def update_quantity
    @cart_item = current_cart.cart_items.find(params[:id])
    case params['type']
    when 'quantity-minus'
      @cart_item.decrement_quantity
    when 'quantity-plus'
      @cart_item.increment_quantity
    end
    p = PriceManagerForCartItem.new(@cart_item)
    @origin_price = p.origin_price
    @discounted_price = p.discounted_price
    @subtotal = p.subtotal
    @gift_info = p.gift_info
    calculate_cart_price
    render "update_cart_price"
  end

  def update_spec
    item = current_cart.cart_items.includes(:item).find(params[:id])
    item.update_attribute(:item_spec_id,  params['item_spec'])
    render json: { spec_style_pic: item.item_spec.style_pic.url }
  end

  def destroy
    current_cart.cart_items.find(params[:id]).destroy
    if current_cart.cart_items.empty?
      flash[:notice] = " 您的購物車目前是空的，快點加入您喜愛的商品吧！"
      render :js => "window.location = '/'"
    else
      calculate_cart_price
      render "update_cart_price"
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id)
  end
end
