module OrderConcern
  extend ActiveSupport::Concern

  included do
    after_update :notify_user_if_arrive_store, :set_blacklisted_if_not_pickup, :update_order_status_if_goods_arrive_store_or_pickup
  end

  def notify_user_if_arrive_store
    if (status_changed? && status == "已到店")
      email_to_notify_pickup
      UserNotifyService.new(user).notify_to_pick_up(self)
    end
  end

  def set_blacklisted_if_not_pickup
    if status == "未取訂貨"
      set_to_blacklist
    end
  end

  def update_order_status_if_goods_arrive_store_or_pickup
    if logistics_status_code_changed? && logistics_status_code == Logistics_Status.key("門市配達")
      update_columns(status: Order.statuses["已到店"])
      email_to_notify_pickup
      UserNotifyService.new(user).notify_to_pick_up(self)
    elsif logistics_status_code_changed? && logistics_status_code == Logistics_Status.key("消費者成功取件")
      update_columns(status: Order.statuses["完成取貨"])
    elsif logistics_status_code_changed? && logistics_status_code == Logistics_Status.key("廠商未至門市取退貨，商品已退回至大智通")
      update_columns(status: Order.statuses["未取訂貨"])
    end
  end

  private

  def email_to_notify_pickup
    OrderMailer.delay.notify_user_pikup_item(self)
  end

  def set_to_blacklist
    OrderBlacklist.find_or_create_by(email: ship_email, phone: ship_phone)
    update_column(:is_blacklisted, true)
  end
end