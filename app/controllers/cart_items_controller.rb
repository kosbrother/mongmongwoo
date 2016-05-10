class CartItemsController < ApplicationController

  def create

    CartItem.create(cart_item_params)

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
