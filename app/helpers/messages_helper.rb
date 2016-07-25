module MessagesHelper
  def select_message_type(user)
    user.id ? Message.message_types["個人訊息"] : Message.message_types["萌萌屋官方訊息"]
  end
end