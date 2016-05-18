module Admin::SalesReportsHelper
  def all_time_tab_active(time_param)
    time_param.nil? ? "active" : ""
  end

  def option_time_tab_active(time_param, time_option)
    css_class = ""

    if time_param.present? && request.original_url.include?("time_field=" + time_option)
      css_class = "active"
    end

    return css_class
  end

  def display_date(time)
    time.strftime("%Y-%m-%d")
  end

  def get_taobao_supplier_name(supplier_id)
    "查詢的商家：#{TaobaoSupplier.find(supplier_id).name}" if supplier_id
  end

  def li_sales_link_all_time_and_supplier(link_text)
    content_tag(:li, '', class: all_time_tab_active(params[:time_field])) do
      link_to link_text, item_sales_result_admin_sales_reports_path(supplier_id: params[:supplier_id])
    end
  end

  def li_sales_link_with_periods_and_supplier(time_option, link_text)
    content_tag(:li, '', class: option_time_tab_active(params[:time_field], time_option)) do
      link_to link_text, item_sales_result_admin_sales_reports_path(time_field: time_option, supplier_id: params[:supplier_id])
    end
  end

  def li_revenue_link_all_time_and_supplier(link_text)
    content_tag(:li, '', class: all_time_tab_active(params[:time_field])) do
      link_to link_text, item_revenue_result_admin_sales_reports_path(supplier_id: params[:supplier_id])
    end
  end

  def li_revenue_link_with_periods_and_supplier(time_option, link_text)
    content_tag(:li, '', class: option_time_tab_active(params[:time_field], time_option)) do
      link_to link_text, item_revenue_result_admin_sales_reports_path(time_field: time_option, supplier_id: params[:supplier_id])
    end
  end
end