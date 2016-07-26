class Api::V3::MyMessagesController < ApiController
  def index
    user = User.find(params[:user_id])
    messages = user.my_messages.select_api_fields

    render status: 200, json: { data: messages }
  end

  def show
    user = User.find(params[:user_id])
    message = user.my_messages.select_api_fields.find(params[:id])

    render status: 200, json: { data: message }
  end
end