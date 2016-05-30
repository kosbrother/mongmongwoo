class Admin::SalesReportsController < AdminController
  before_action :require_manager

  def item_sales_result
    @item_sales = get_item_sales(params)
  end

  def item_revenue_result
    @item_revenue = get_item_revenue(params)
  end

  def cost_statistics_index
    @cost_statistics = CostStatistic.by_cost_date_recent.paginate(:page => params[:page])
  end

  def cost_statistics_create
    @cost_statistic = CostStatistic.create!(cost_statistic_params)
    redirect_to cost_statistics_index_admin_sales_reports_path
  end

  def sales_income_result
    if params[:start_cost_date] && params[:end_cost_date]
      @total_sales_income, @total_cost_of_goods = get_period_total_sales_income_and_cost_of_goods
      @total_cost_of_freight_in, @total_cost_of_advertising = get_period_total_cost_data_of_goods_freight_in_and_advertising
      @total_order_quantity, @total_cost_ship_fee = get_period_total_order_data_of_quantity_and_cost_ship_fee
      @cancelled_order_quantity, @cancelled_order_amount, @cancelled_order_ship_fee = get_period_total_cancelled_order_data_of_quantity_amount_and_ship_fee
      @gross_profit = (@total_sales_income - @total_cost_of_goods - @total_cost_of_freight_in - @total_cost_ship_fee)
      @gross_profit_per_order = get_division_operator_value(@gross_profit, @total_order_quantity)
      @average_cost_of_advertising = get_division_operator_value(@total_cost_of_advertising, @total_order_quantity)
      @average_gross_profit_except_ads = @gross_profit_per_order - @average_cost_of_advertising
      @actual_gross_profit = @gross_profit - @cancelled_order_amount
      @actual_average_gross_profit = get_division_operator_value(@actual_gross_profit, (@total_order_quantity - @cancelled_order_quantity))
    end
  end

  private

  def time_until_range
    TimeSupport.time_until(params[:time_field])
  end

  def cost_statistic_params
    params.require(:cost_statistic).permit(:cost_of_advertising, :cost_of_freight_in, :cost_date)
  end

  def search_date_params
    TimeSupport.dynamic_time_until(params[:start_cost_date], params[:end_cost_date])
  end

  def get_period_total_sales_income_and_cost_of_goods
    total_income_and_cost = OrderItem.created_at_within(search_date_params).total_income_and_cost[0]
    [total_income_and_cost.total_sales_income, (total_income_and_cost.total_cost_of_goods) * 5]
  end

  def get_period_total_cost_data_of_goods_freight_in_and_advertising
    total_cost_bunch_data = CostStatistic.cost_date_within(search_date_params).select("COALESCE(SUM(cost_of_freight_in), 0) AS total_cost_of_freight_in", "COALESCE(SUM(cost_of_advertising), 0) AS total_cost_of_advertising")[0].as_json.to_a.map { |data_name| data_name[1] }
    total_cost_bunch_data.shift
    total_cost_bunch_data
  end
  
  def get_period_total_order_data_of_quantity_and_cost_ship_fee
    total_order_bunch_data = Order.created_at_within(search_date_params).select("COUNT(*) AS total_order_quantity", "COALESCE(SUM(ship_fee), 0) AS total_cost_ship_fee")[0].as_json.to_a.map { |data_name| data_name[1] }
    total_order_bunch_data.shift
    total_order_bunch_data
  end
  
  def get_period_total_cancelled_order_data_of_quantity_amount_and_ship_fee
    cancelled_order_bunch_data = Order.cancelled_at_within(search_date_params).select("COUNT(*) AS cancelled_order_quantity", "COALESCE(SUM(items_price), 0) AS cancelled_order_amount", "COALESCE(SUM(ship_fee), 0) AS cancelled_order_ship_fee")[0].as_json.to_a.map { |data_name| data_name[1] }
    cancelled_order_bunch_data.shift
    cancelled_order_bunch_data
  end

  def get_division_operator_value(value_1, value_2)
    value_1 / value_2
    rescue ZeroDivisionError
    0
  end

  def get_item_sales(params)
    if(params[:time_field] && params[:supplier_id])
      OrderItem.sort_by_sales.created_at_within(time_until_range).with_supplier(params[:supplier_id])
    elsif(params[:supplier_id])
      OrderItem.sort_by_sales.with_supplier(params[:supplier_id])
    elsif(params[:time_field])
      OrderItem.sort_by_sales.created_at_within(time_until_range)
    else
      OrderItem.sort_by_sales
    end
  end

  def get_item_revenue(params)
    if(params[:time_field] && params[:supplier_id])
      OrderItem.sort_by_revenue.created_at_within(time_until_range).with_supplier(params[:supplier_id])
    elsif(params[:supplier_id])
      OrderItem.sort_by_revenue.with_supplier(params[:supplier_id])
    elsif(params[:time_field])
      OrderItem.sort_by_revenue.created_at_within(time_until_range)
    else
      OrderItem.sort_by_revenue
    end
  end
end