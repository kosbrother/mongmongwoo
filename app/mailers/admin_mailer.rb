class AdminMailer < ApplicationMailer
  def notify_recommend_stock
    @recommend_stock = ItemSpec.includes(:stock_spec, item: :taobao_supplier, admin_cart_items: :admin_cart).order(item_id: :ASC)
    @recommend_off_shelf = ItemSpec.includes(:stock_spec, item: :taobao_supplier).recommend_stock_empty
    @daily_order_quantity = Order.daily_order_quantity
    @daily_sales_income = OrderItem.daily_sales_income
    admin_emails = %w(stevenko@kosbrother.com ping.lin@kosbrother.com jason@kosbrother.com)
    Rails.logger.warn("mail to : #{admin_emails}")
    mail(to: admin_emails, :subject => "[萌萌屋] 推薦庫存不足與推薦下架的樣式清單")
  end
end