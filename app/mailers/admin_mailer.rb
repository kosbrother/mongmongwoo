class AdminMailer < ApplicationMailer
  def notify_recommend_stock
    xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "admin/sales_reports/export_daily_reports"
    attachments["export_daily_reports.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}
    admin_emails = %w(stevenko@kosbrother.com ping.lin@kosbrother.com jason@kosbrother.com)
    Rails.logger.warn("mail to : #{admin_emails}")
    mail(to: admin_emails, :subject => "[萌萌屋] 推薦庫存不足與推薦下架的樣式清單")
  end
end