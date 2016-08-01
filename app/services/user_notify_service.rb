class UserNotifyService

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def notify_wish_list_user(wish_list)
    user.messages.create(wish_list_message_params(wish_list.item.name, wish_list.item_spec.style))
  end

  private

  def wish_list_message_params(item_name, spec_style)
    {title: "熱賣品回鍋～#{item_name} 款式：#{spec_style}，千呼萬喚上架了！",
     content: "#{item_name} 款式：#{spec_style} 已經開放訂購了，庫存有限要買要快！",
     message_type: Message.message_types["個人訊息"]}
  end
end