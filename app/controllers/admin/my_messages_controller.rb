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

    if @message.save(validate: false)
      device_id = DeviceRegistration.find(@user.device_id).registration_id
      GcmNotifyService.new.send_message_notification(device_id, @message)
      logger.info("Sending notification to device: #{device_id}")
      flash[:notice] = "已成功推播新增的個人訊息"
      redirect_to admin_user_my_messages_path(@user)
    else
      flash[:danger] = "請確認訊息內容是否正確"
      render :new
    end
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def message_params
    params.require(:message).permit(:title, :content, :message_type, user_ids: [])
  end
end