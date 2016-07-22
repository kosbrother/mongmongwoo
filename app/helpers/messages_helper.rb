module MessagesHelper
  def select_message_type
    params[:user_id] ? Message.message_types["個人訊息"] : Message.message_types["萌萌屋官方訊息"]
  end

  def notification_button(message)
    if params[:device_registration_id]
      link_to "送出推播", send_notify_message_admin_messages_path(message_id: message.id, device_registration_id: params[:device_registration_id]), method: :post, class: "btn btn-default"
    else
      "找不到裝置ID"
    end
  end
end