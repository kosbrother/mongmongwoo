module MessagesHelper
  def select_message_type(user=nil)
    if user.present?
      Message.message_types["個人訊息"]
    else
      Message.message_types["萌萌屋官方訊息"]
    end
  end
end