class CartItemsController < ApplicationController

  def create
    CartItem.create(cart_item_params)
  end

  def update_quantity
    item = current_cart.cart_items.find(params[:id])
    case params['type']
    when 'quantity-minus'
      item.decrement_quantity
    when 'quantity-plus'
      item.increment_quantity
    end
    items = current_cart.cart_items.includes(:item)
    render json: subtotal_and_total_with_shipping(item, items)
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
      items = current_cart.cart_items.includes(:item)
      render json: total_with_shipping(items)
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id, :item_quantity).merge({ cart_id: current_cart.id})
  end

  def subtotal_and_total_with_shipping(item, items)
    { subtotal: "NT.#{item.subtotal}", total: "NT.#{total(items)}", ship_fee:"NT.#{ship_fee(items)}", total_with_shipping: "NT.#{total(items) + ship_fee(items)}" }
  end

  def total_with_shipping(items)
    { total: "NT.#{total(items)}", ship_fee:"NT.#{ship_fee(items)}", total_with_shipping: "NT.#{total(items) + ship_fee(items)}" }
  end

end
