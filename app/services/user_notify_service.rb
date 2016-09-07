class UserNotifyService

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def wish_list_item_spec_on_shelf(item_spec)
    message = user.messages.create(item_spec_on_shelf_params(item_spec.item, item_spec.style))
    send_wish_list_message_to_user(message) if user.device_id
  end

  def wish_list_item_spec_arrival(item_spec)
    message = user.messages.create(item_spec_arrival_params(item_spec.item, item_spec.style))
    send_wish_list_message_to_user(message) if user.device_id
  end

  def notify_to_pick_up(order)
    message = user.messages.create(order_message_params(order)) if !(user.anonymous_user?)

    if order.device_registration
      registration_id = [order.device_registration.registration_id]
      options = GcmOptionsGenerator.generate_options_for_pickup(order.id, message)
      GcmNotifyService.new.send_pickup_notification(registration_id, options)
    end
  end

  private

  def item_spec_on_shelf_params(item, spec_style)
    {title: "熱賣品回鍋～#{item.name} 款式：#{spec_style}，千呼萬喚上架了！",
     content: "#{item.name} 款式：#{spec_style} 已經開放訂購了，庫存有限要買要快！",
     messageable: item,
     message_type: Message.message_types["個人訊息"]}
  end

  def item_spec_arrival_params(item, spec_style)
    {title: "熱騰騰的～#{item.name} 款式：#{spec_style}，新鮮到貨了！",
     content: "#{item.name} 款式：#{spec_style} 已經有現貨了，數量有限，要買要快！",
     messageable: item,
     message_type: Message.message_types["個人訊息"]}
  end

  def order_message_params(order)
    {title: "萌萌屋取貨通知",
     content: "#{order.ship_name} 您好，您訂購的商品已送達#{order.ship_store_name}門市，請於七日內完成取貨。若有任何問題，請聯繫萌萌屋客服。",
     message_type: Message.message_types["個人訊息"]}
  end

  def send_wish_list_message_to_user(message)
    registration_id = [DeviceRegistration.find(user.device_id).registration_id]
    options = GcmOptionsGenerator.generate_options_for_send_message(message)
    GcmNotifyService.new.send_message_notification(registration_id, options)
  end
end