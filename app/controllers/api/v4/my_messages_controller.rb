class Api::V4::MyMessagesController < ApiController
  def index
    user = User.find(params[:user_id])
    messages = user.my_messages.order(id: :desc).as_json(only: [:id, :message_type, :title, :content, :created_at], methods: :app_index_url)

    render status: 200, json: { data: messages }
  end
end