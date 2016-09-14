class UserNotifyService

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def self.item_event_notification(notification)
    options = GcmOptionsGenerator.generate_item_event_options_from_notification(notification)
    DeviceRegistration.select(:id, :registration_id).find_in_batches do |ids|
      registration_ids = ids.map(&:registration_id)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  def self.wish_list_on_shelf(item_spec)
    item_spec.wish_lists.each do |wish_list|
      user = wish_list.user
      if Message.user_has_message?(user, wish_list) == false
        message = user.messages.create(wish_list_on_shelf_message_params(wish_list))
        if user.device_id
          registration_ids = [DeviceRegistration.find(user.device_id).registration_id]
          options = GcmOptionsGenerator.generate_personal_notify_options_from_message(message)
          GcmNotifyService.new.send_notification(registration_ids, options)
        end
      end
    end
  end

  def self.wish_list_arrival(item_spec)
    item_spec.wish_lists.each do |wish_list|
      user = wish_list.user
      if Message.user_has_message?(user, wish_list) == false
        message = user.messages.create(wish_list_arrival_message_params(wish_list))
        if user.device_id
          registration_ids = [DeviceRegistration.find(user.device_id).registration_id]
          options = GcmOptionsGenerator.generate_personal_notify_options_from_message(message)
          GcmNotifyService.new.send_notification(registration_ids, options)
        end
      end
    end
  end

  def self.send_personal_notification(device_id, message)
    registration_ids = [DeviceRegistration.find(device_id).registration_id]
    options = GcmOptionsGenerator.generate_personal_notify_options_from_message(message)
    GcmNotifyService.new.send_notification(registration_ids, options)
  end

  def notify_to_pick_up(order)
    if user.anonymous_user?
      message = Message.create(order_message_params(order))
    else
      message = user.messages.create(order_message_params(order))
    end

    if order.device_registration
      registration_ids = [order.device_registration.registration_id]
      options = GcmOptionsGenerator.generate_pick_up_options_from_message(message)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  def notify_user_to_buy(wish_list)
    message = user.messages.create(notify_to_buy_message_params(wish_list))

    if user.device_id
      registration_ids = [DeviceRegistration.find(user.device_id).registration_id]
      options = GcmOptionsGenerator.generate_personal_notify_options_from_message(message)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  private

  def self.wish_list_on_shelf_message_params(wish_list)
    {title: "熱賣品回鍋～#{wish_list.item.name} 款式：#{wish_list.item_spec.style}，千呼萬喚上架了！",
     content: "#{wish_list.item.name} 款式：#{wish_list.item_spec.style} 已經開放訂購了，庫存有限要買要快！",
     messageable: wish_list,
     message_type: Message.message_types["個人訊息"]}
  end

  def self.wish_list_arrival_message_params(wish_list)
    {title: "熱騰騰的～#{wish_list.item.name} 款式：#{wish_list.item_spec.style}，新鮮到貨了！",
     content: "#{wish_list.item.name} 款式：#{wish_list.item_spec.style} 已經有現貨了，數量有限，要買要快！",
     messageable: wish_list,
     message_type: Message.message_types["個人訊息"]}
  end

  def order_message_params(order)
    {title: "萌萌屋取貨通知",
     content: "#{order.ship_name} 您好，您訂購的商品已送達#{order.ship_store_name}門市，請於七日內完成取貨。若有任何問題，請聯繫萌萌屋客服。",
     messageable: order,
     message_type: Message.message_types["個人訊息"]}
  end

  def notify_to_buy_message_params(wish_list)
    {title: "熱賣品～#{wish_list.item.name} 款式：#{wish_list.item_spec.style}，快來搶購！",
     content: "#{wish_list.item.name} 款式：#{wish_list.item_spec.style} 有現貨喔，數量有限，要買要快！",
     messageable: wish_list,
     message_type: Message.message_types["個人訊息"]}
  end
end