class OrdersController < ApplicationController
  layout 'user'

  before_action  :load_categories, :require_user

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
    @items = @order.items.includes(:item_spec)
    @info = @order.info
  end
end
