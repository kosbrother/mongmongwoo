class OrderMailer < ApplicationMailer
  helper PriceHelper

  def notify_order_placed(order)
    @order = order
    @order_items = @order.items.includes(:item_spec)
    @order_info  = @order.info
    Rails.logger.warn("mail to : #{@order_info.ship_email}")
    mail(to: @order_info.ship_email , subject: "[萌萌屋] 感謝您完成本次的選購")
  end

  def notify_user_pikup_item(order)
    @order       = order
    @order_info  = @order.info
    @ship_store = Store.find_by(store_code: @order_info.ship_store_code)
    Rails.logger.warn("mail to : #{@order_info.ship_email}")
    mail(to: @order_info.ship_email , subject: "[萌萌屋] 貨物到店通知")
  end

  def satisfaction_survey(order)
    @order       = order
    @order_info  = @order.info
    Rails.logger.warn("mail to : #{@order_info.ship_email}")
    mail(to: @order_info.ship_email , subject: "[萌萌屋] 購物滿意度調查")
  end
end