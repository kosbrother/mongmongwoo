class OrdersController < ApplicationController
  layout 'user'
  before_action  :load_categories_and_campaigns, :require_user

  def index
    @orders = current_user.orders.exclude_unpaid_credit_card_orders.recent
    set_meta_tags title: "我的訂單", noindex: true
  end

  def show
    @order = current_user.orders.includes(:discount_records, shopping_point_records: {shopping_point: :shopping_point_campaign}).find(params[:id])
    @order_items = @order.items.includes(:item_spec, :discount_record)
    @info = @order.info
    @shopping_point_amount = @order.shopping_point_spend_amount
    @reduced_items_price = @order.calculate_reduced_items_price
    @discount_records = @order.discount_records
    @shopping_point_records = @order.shopping_point_records.where("amount > 0")
    set_meta_tags title: "訂單內容", noindex: true
  end

  def cancel
    order = current_user.orders.find(params[:id])
    order.update(status: Order.statuses["訂單取消"])
    flash[:notice] = "已成功取消訂單"

    redirect_to :back
  end
end
