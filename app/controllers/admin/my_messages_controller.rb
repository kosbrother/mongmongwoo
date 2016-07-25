class Admin::MyMessagesController < AdminController
  before_action :require_manager
  before_action :find_user, only: [:index, :new, :create]

  def index
    @messages = @user.my_messages
  end

  def new
    @message = @user.messages.new
  end

  def create
    @message = @user.messages.new(message_params)
    @message.save(validate: false)
    send_message_notify
    redirect_to :back
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def message_params
    params.require(:message).permit(:title, :content, :message_type, user_ids: [])
  end

  def send_message_notify
    if params[:device_registration_id].blank?
      flash[:notice] = "已成功新增個人訊息"
    else
      device_id = DeviceRegistration.find(params[:device_registration_id]).registration_id
      GcmNotifyService.new.send_message_notification(device_id, @message)
      logger.info("Sending notification to device: #{device_id}")
      flash[:notice] = "已成功推播新增的個人訊息"
    end
  end
end