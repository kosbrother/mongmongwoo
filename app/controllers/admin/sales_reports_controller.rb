class Admin::SalesReportsController < AdminController
  before_action :require_manager

  def item_sales_result
    if %w[month week day].include?(params[:time_field])
      @item_sales = OrderItem.sort_by_sales(params[:time_field])
    else
      @item_sales = OrderItem.default_sales
    end
  end

  def item_revenue_result
    if %w[month week day].include?(params[:time_field])
      @item_revenue = OrderItem.sort_by_revenue(params[:time_field])
    else
      @item_revenue = OrderItem.default_revenue
    end
  end
end