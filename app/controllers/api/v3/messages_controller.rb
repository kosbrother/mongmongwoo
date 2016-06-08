class Api::V3::MessagesController < ApiController
  def index
    @messages = Message.official_messages.select_api_fields.paginate(:page => params[:page])

    render json: @messages
  end

  def show
    @message = Message.select_api_fields.find(params[:id])

    render json: @message
  end
end