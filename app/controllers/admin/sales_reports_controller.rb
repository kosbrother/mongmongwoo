class Admin::SalesReportsController < AdminController
  before_action :require_manager

  def item_sales_result
    @item_sales = OrderItem.includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity) as sum_item_quantity").order("sum_item_quantity DESC")
  end

  def item_revenue_result
    @item_revenue = OrderItem.includes(:item, item: :categories).group(:source_item_id).select(:id, :item_name, :source_item_id, "SUM(item_quantity * item_price) as sum_item_revenue").order("sum_item_revenue DESC")
  end
end