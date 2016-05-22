class OrdersController < ApplicationController
  layout 'user'

  before_action  :load_categories

  def index
    @orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
    @items = @order.items.includes(:item_spec)
    @info = @order.info
  end
end
