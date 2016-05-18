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
end