class OrdersController < ApplicationController
  layout 'user'

  before_action  :load_categories, :require_user

  def index
    @orders = current_user.orders.recent
    set_meta_tags title: "我的訂單", noindex: true
  end

  def show
    @order = current_user.orders.find(params[:id])
    @items = @order.items.includes(:item_spec)
    @info = @order.info
    set_meta_tags title: "訂單內容", noindex: true
  end
end
