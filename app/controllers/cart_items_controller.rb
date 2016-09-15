class CartItemsController < ApplicationController

  def create
    cart_item = current_cart.cart_items.find_or_create_by(cart_item_params)
    cart_item.increment_quantity(params[:cart_item][:item_quantity].to_i)
  end

  def update_quantity
    item = current_cart.cart_items.find(params[:id])
    case params['type']
    when 'quantity-minus'
      item.decrement_quantity
    when 'quantity-plus'
      item.increment_quantity
    end
    render json: subtotal_and_total_with_shipping(item)
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
      render json: total_with_shipping
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id)
  end

  def subtotal_and_total_with_shipping(item)
    { subtotal: "NT$ #{item.subtotal}", items_price: "NT$ #{current_cart.calculate_items_price}", reduced_items_price: "NT$ #{current_cart.calculate_reduced_items_price}", ship_fee:"NT$ #{current_cart.calculate_ship_fee}", total: "NT$ #{current_cart.calculate_total}" }
  end

  def total_with_shipping
    { items_price: "NT$ #{current_cart.calculate_items_price}", reduced_items_price: "NT$ #{current_cart.calculate_reduced_items_price}", ship_fee:"NT$ #{current_cart.calculate_ship_fee}", total: "NT$ #{current_cart.calculate_total}" }
  end
end
