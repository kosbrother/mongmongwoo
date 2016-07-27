class AdminMailer < ApplicationMailer
  def notify_recommend_stock
    @recommend_stock = ItemSpec.includes(:stock_spec, item: :taobao_supplier, admin_cart_items: :admin_cart).order(item_id: :ASC)

    @recommend_off_shelf = ItemSpec.includes(:stock_spec, item: :taobao_supplier).recommend_stock_empty

    @daily_order_quantity = Order.created_at_within(Date.today.prev_day(1)..Date.today).select("COUNT(*) AS total_order_quantity")[0]["total_order_quantity"]

    @daily_sales_income = OrderItem.created_at_within(Date.today.prev_day(1)..Date.today).joins(:item).select("COALESCE(SUM(order_items.item_quantity * order_items.item_price), 0) AS total_sales_income ")[0]["total_sales_income"]


    # xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], locals: {recommend_stock: @recommend_stock}
    # attachments["recommend_stock.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}


    admin_emails = %w(stevenko@kosbrother.com ping.lin@kosbrother.com jason@kosbrother.com)
    Rails.logger.warn("mail to : #{admin_emails}")
    mail(to: admin_emails, :subject => "[萌萌屋] 推薦庫存不足與推薦下架的樣式清單")
  end
end