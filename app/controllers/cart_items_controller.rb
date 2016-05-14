class CartItemsController < ApplicationController
  before_action :verify_item_belong_cart, only: [:update_quantity, :update_spec, :destroy]
  skip_before_action :load_categories, :load_popular_items

  def create
    @cart = Cart.find(session[:cart_id])
    item = @cart.cart_items.find_by_item_spec_id(params[:cart_item][:item_spec_id])
    if item.present?
      quantity = params[:cart_item][:item_quantity].to_i
      item.increment_quantity(quantity)
    else
      CartItem.create(cart_item_params)
    end
    respond_to do |format|
      format.js
    end
  end

  def update_quantity
    item = CartItem.find(params[:id])
    items = @cart.cart_items
    case params['type']
    when 'quantity-minus'
      item.decrement_quantity
      render json: return_subtotal_and_total_with_shipping(item, items)
    when 'quantity-plus'
      item.increment_quantity
      render json: return_subtotal_and_total_with_shipping(item, items)
    end
  end

  def update_spec
    item = CartItem.find(params[:id])
    item.item_spec_id = params['item_spec']
    item.save!
    render json: { spec_style_pic: item.item_spec.style_pic.url }
  end

  def destroy
    item = CartItem.find(params[:id])
    item.destroy
    @cart.reload
    if @cart.cart_items.empty?
      remove_car_result
    else
      render nothing: true
    end
  end


  private

  def cart_item_params
    params.require(:cart_item).permit(:item_id, :item_spec_id, :item_quantity).merge({ cart_id: @cart.id})
  end

  def verify_item_belong_cart
    @cart = Cart.includes({cart_items: :item}).find(session[:cart_id])
    unless @cart.cart_items.exists?(params[:id])
      head(403)
    end
  end

  def return_subtotal_and_total_with_shipping(item, items)
    { subtotal: "NT.#{item.subtotal}", total: "NT.#{items_total(items)}", total_with_shipping: "NT.#{items_total(items)+60}" }
  end

  def remove_car_result
    respond_to do |format|
    format.js { render 'remove_cart_result' }
    end
  end

end
