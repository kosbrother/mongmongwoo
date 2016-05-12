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
    if @cart.cart_items.empty?
      respond_to do |format|
        format.js { render 'remove-submit' }
      end
    else
      render json: { subtotal: "NT.#{@item.subtotal}", total: "NT.#{@cart.total}", total_with_shipping: "NT.#{@cart.total+60}" }
    end

  end

  def destroy

    @item = CartItem.find(params[:id])
    @item.destroy
    if @cart.cart_items.empty?
      respond_to do |format|
        format.js { render 'remove-submit' }
      end
    else
      render :nothing => true
    end

  end


  private

  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id, :item_quantity).merge({ cart_id: @cart.id})
  end

  def remove_submit_if_no_items
    if @cart.cart_items.empty?
      respond_to do |format|
        format.js { render 'remove-submit' }
      end
    end
  end

end
