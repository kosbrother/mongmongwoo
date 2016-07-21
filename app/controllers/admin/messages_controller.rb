class Admin::MessagesController < AdminController
  before_action :require_manager
  before_action :find_user, only: [:my_messages, :my_new_message, :create_my_message]

  def index
    @messages = Message.official_messages.paginate(:page => params[:page])
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      flash[:notice] = "成功新增官方訊息"
      redirect_to admin_messages_path
    else
      flash[:danger] = "請檢查訊息內容是否有誤"
      render :new
    end
  end

  def show
    @message = Message.find(params[:id])
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    flash[:warning] = "訊息已刪除"
    redirect_to admin_messages_path
  end

  def my_messages
    @messages = Message.personal_and_official(@user)
  end

  def my_new_message
    @message = @user.messages.new
  end

  def create_my_message
    @message = @user.messages.new(message_params)

    if @message.save
      flash[:notice] = "成功新增個人訊息"
      redirect_to my_messages_admin_messages_path(@user)
    else
      flash.now[:danger] = "請檢查訊息內容是否有誤"
      render :my_new_message
    end
  end

  private

  def message_params
    params.require(:message).permit(:title, :content, :message_type, user_ids: [])
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end