class Api::V3::MyMessagesController < ApiController
  def index
    user = User.find(params[:user_id])
    messages = user.my_messages.select_api_fields

    render status: 200, json: { data: messages }
  end
end