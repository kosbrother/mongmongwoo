class SeedRegisterMessageToAnnonymousUser < ActiveRecord::Migration
  def up
    message = Message.create(message_type: Message.message_types["個人訊息"],messageable_id: ShoppingPointCampaign::REGISTER_ID, messageable_type: ShoppingPointCampaign.name, title: "註冊就送購物金活動", content: "現在註冊就送購物金")
    message.message_records.create(user_id: User::ANONYMOUS)
  end

  def down
    message = Message.find_by(messageable_id: ShoppingPointCampaign::REGISTER_ID)
    message.destroy if message
  end
end
