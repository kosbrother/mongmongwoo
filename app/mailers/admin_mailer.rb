class AdminMailer < ApplicationMailer
  def notify_recommend_stock
    @stock_shortage_specs = ItemSpec.includes(:item).on_shelf.stock_shortage
    @recommend_off_shelf_spec = ItemSpec.includes(:item).on_shelf.recommend_stock_empty
    admin_emails = %w(stevenko@kosbrother.com ping.lin@kosbrother.com jason@kosbrother.com)
    Rails.logger.warn("mail to : #{admin_emails}")
    mail(to: admin_emails, :subject => "[萌萌屋] 推薦庫存不足與推薦下架的樣式清單")
  end
end