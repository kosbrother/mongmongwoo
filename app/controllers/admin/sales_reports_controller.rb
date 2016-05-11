class Admin::SalesReportsController < AdminController
  before_action :require_manager

  def item_sales_result
    if %w[month week day].include?(params[:time_field])
      @item_sales = OrderItem.created_at_within(time_until_range).sort_by_sales
    else
      @item_sales = OrderItem.sort_by_sales
    end
  end

  def item_revenue_result
    if %w[month week day].include?(params[:time_field])
      @item_revenue = OrderItem.created_at_within(time_until_range).sort_by_revenue
    else
      @item_revenue = OrderItem.sort_by_revenue
    end
  end

  def cost_statistics_index
    @cost_statistics = CostStatistic.cost_date_at.paginate(:page => params[:page])
  end

  def cost_statistics_create
    @cost_statistic = CostStatistic.create!(cost_statistic_params)
    redirect_to cost_statistics_index_admin_sales_reports_path
  end

  private

  def time_until_range
    TimeSupport.time_until(params[:time_field])
  end

  def cost_statistic_params
    params.require(:cost_statistic).permit(:cost_of_goods, :cost_of_advertising, :cost_of_freight_in, :cost_date)
  end
end