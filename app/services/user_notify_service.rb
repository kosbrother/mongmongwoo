class UserNotifyService

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def self.item_event_notification(notification)
    options = GcmOptionsGenerator.generate_options_from_notification(notification)
    DeviceRegistration.select(:id, :registration_id).find_in_batches do |ids|
      registration_ids = ids.map(&:registration_id)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  def self.wish_list_on_shelf(item_spec)
    item_spec.wish_lists.each do |wish_list|
      unless wish_list.user.messages.wish_list_message_present?(wish_list.item)
        message = wish_list.user.messages.create(item_spec_on_shelf_message_params(wish_list.item_spec))
        if wish_list.user.device_id
          registration_ids = [DeviceRegistration.find(wish_list.user.device_id).registration_id]
          options = GcmOptionsGenerator.generate_options_from_message(message)
          GcmNotifyService.new.send_notification(registration_ids, options)
        end
      end
    end
  end

  def self.wish_list_arrival(item_spec)
    item_spec.wish_lists.each do |wish_list|
      unless wish_list.user.messages.wish_list_message_present?(wish_list.item)
        message = wish_list.user.messages.create(item_spec_arrival_message_params(wish_list.item_spec))
        if wish_list.user.device_id
          registration_ids = [DeviceRegistration.find(wish_list.user.device_id).registration_id]
          options = GcmOptionsGenerator.generate_options_from_message(message)
          GcmNotifyService.new.send_notification(registration_ids, options)
        end
      end
    end
  end

  def self.send_personal_notification(device_id, message)
    registration_ids = [DeviceRegistration.find(device_id).registration_id]
    options = GcmOptionsGenerator.generate_options_from_message(message)
    GcmNotifyService.new.send_notification(registration_ids, options)
  end

  def notify_to_pick_up(order)
    message = user.messages.create(order_message_params(order)) if !(user.anonymous_user?)

    if order.device_registration
      registration_ids = [order.device_registration.registration_id]
      options = GcmOptionsGenerator.generate_options_from_order_id_and_message(order.id, message)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  def notify_user_to_buy(item_spec)
    message = user.messages.create(notify_to_buy_message_params(item_spec))

    if user.device_id
      registration_ids = [DeviceRegistration.find(user.device_id).registration_id]
      options = GcmOptionsGenerator.generate_options_from_message(message)
      GcmNotifyService.new.send_notification(registration_ids, options)
    end
  end

  private

  def self.item_spec_on_shelf_message_params(item_spec)
    {title: "熱賣品回鍋～#{item_spec.item.name} 款式：#{item_spec.style}，千呼萬喚上架了！",
     content: "#{item_spec.item.name} 款式：#{item_spec.style} 已經開放訂購了，庫存有限要買要快！",
     messageable: item_spec.item,
     message_type: Message.message_types["個人訊息"]}
  end

  def self.item_spec_arrival_message_params(item_spec)
    {title: "熱騰騰的～#{item_spec.item.name} 款式：#{item_spec.style}，新鮮到貨了！",
     content: "#{item_spec.item.name} 款式：#{item_spec.style} 已經有現貨了，數量有限，要買要快！",
     messageable: item_spec.item,
     message_type: Message.message_types["個人訊息"]}
  end

  def order_message_params(order)
    {title: "萌萌屋取貨通知",
     content: "#{order.ship_name} 您好，您訂購的商品已送達#{order.ship_store_name}門市，請於七日內完成取貨。若有任何問題，請聯繫萌萌屋客服。",
     message_type: Message.message_types["個人訊息"]}
  end

  def notify_to_buy_message_params(item_spec)
    {title: "熱賣品～#{item_spec.item.name} 款式：#{item_spec.style}，快來搶購！",
     content: "#{item_spec.item.name} 款式：#{item_spec.style} 有現貨喔，數量有限，要買要快！",
     messageable: item_spec.item,
     message_type: Message.message_types["個人訊息"]}
  end
end