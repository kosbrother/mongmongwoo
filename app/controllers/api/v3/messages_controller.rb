class Api::V3::MessagesController < ApiController
  def index
    messages = Message.official_messages.select_api_fields.paginate(:page => params[:page])

    render status: 200, json: { data: messages }
  end

  def show
    message = Message.select_api_fields.find(params[:id])

    render status: 200, json: { data: message }
  end
end