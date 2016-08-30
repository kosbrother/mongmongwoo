class UserNotifyService

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def notify_wish_list_user(wish_list)
    message = user.messages.create(wish_list_message_params(wish_list.item.name, wish_list.item_spec.style))
    GcmNotifyService.new.send_message_notification(user.device_id, message) if user.device_id
  end

  def notify_to_pick_up(order)
    message = user.messages.create(order_message_params(order)) if !(user.anonymous_user?)
    GcmNotifyService.new.send_pickup_notification(order, message) if order.device_registration
  end

  private

  def wish_list_message_params(item_name, spec_style)
    {title: "熱賣品回鍋～#{item_name} 款式：#{spec_style}，千呼萬喚上架了！",
     content: "#{item_name} 款式：#{spec_style} 已經開放訂購了，庫存有限要買要快！",
     message_type: Message.message_types["個人訊息"]}
  end

  def order_message_params(order)
    {title: "萌萌屋取貨通知",
     content: "#{order.ship_name} 您好，您訂購的商品已送達#{order.ship_store_name}門市，請於七日內完成取貨。若有任何問題，請聯繫萌萌屋客服。",
     message_type: Message.message_types["個人訊息"]}
  end
end