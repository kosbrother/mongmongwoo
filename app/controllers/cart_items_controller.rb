class CartItemsController < ApplicationController

  def create

    if @cart.cart_items.find_by_item_id(params[:cart_item][:item_id])
      @cart.cart_items.find_by_item_id(params[:cart_item][:item_id]).increment_quantity(params[:cart_item][:item_quantity].to_i)
    else
      CartItem.create(cart_item_params)
    end

    respond_to do |format|
      format.js
    end
  end

  def update

    @item = CartItem.find(params[:id])
    if params['quantity'] == '-'
      @item.decrement_quantity
    elsif params['quantity'] == '+'
      @item.increment_quantity
    end

    render json: { subtotal: "NT.#{@item.subtotal}", total: "NT.#{@cart.total}", total_with_shipping: "NT.#{@cart.total+60}" }

  end

  def destroy

    @item = CartItem.find(params[:id])
    @item.destroy

    render :nothing => true

  end



  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id, :item_quantity).merge({ cart_id: @cart.id})
  end

end
