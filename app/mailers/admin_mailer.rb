class AdminMailer < ApplicationMailer
  helper ApplicationHelper, Admin::ItemsHelper

  def notify_recommend_stock
    recommend_stock = ItemSpec.includes(:stock_spec, item: :taobao_supplier, admin_cart_items: :admin_cart).order(item_id: :ASC)
    recommend_off_shelf = ItemSpec.includes(:stock_spec, item: :taobao_supplier).recommend_stock_empty
    orders = Order.created_at_within(TimeSupport.time_until("day_by_midnight"))
    total_quantity_and_income = orders.count_and_income_fields[0]
    total_quantity, total_income = total_quantity_and_income["quantity"], total_quantity_and_income["income"]
    repurchased_quantity_and_income = orders.where(is_repurchased: true).count_and_income_fields[0]
    repurchased_quantity, repurchased_income = repurchased_quantity_and_income["quantity"], repurchased_quantity_and_income["income"]
    cancel_quantity_and_income = orders.where(status: Order.statuses["訂單取消"]).count_and_income_fields[0]
    cancel_quantity, cancel_income = cancel_quantity_and_income["quantity"], cancel_quantity_and_income["income"]
    xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "admin/sales_reports/export_daily_reports", locals: { recommend_stock: recommend_stock, recommend_off_shelf: recommend_off_shelf, total_quantity: total_quantity, total_income: total_income, repurchased_quantity: repurchased_quantity, repurchased_income: repurchased_income, cancel_quantity: cancel_quantity, cancel_income: cancel_income }, layout: false
    attachments["#{Time.current.strftime("%Y_%m_%d")}_report.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}
    admin_emails = %w(stevenko@kosbrother.com ping.lin@kosbrother.com jason@kosbrother.com beatles1030@gmail.com)
    Rails.logger.warn("mail to : #{admin_emails}")
    mail(to: admin_emails, :subject => "[萌萌屋] 推薦庫存不足與推薦下架的樣式清單") {|format| format.text {render plain: "附件內容：建議庫存，下架清單與昨日銷售"}}
  end
end