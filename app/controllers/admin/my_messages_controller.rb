class Admin::MyMessagesController < AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_user, only: [:index, :new, :create]

  def index
    @messages = @user.my_messages
  end

  def new
    @message = @user.messages.new
  end

  def create
    if (@user.anonymous_user?)
      message = Message.create(message_params)
    else
      message = @user.messages.create(message_params)
    end
    send_message_notify(message)
    redirect_to :back
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def message_params
    params.require(:message).permit(:title, :content, :message_type)
  end

  def send_message_notify(message)
    if params[:device_registration_id].blank?
      flash[:notice] = "已成功新增個人訊息"
    else
      UserNotifyService.send_personal_notification(params[:device_registration_id], message)
      flash[:notice] = "已成功推播新增的個人訊息"
    end
  end
end