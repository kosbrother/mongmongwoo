class Admin::MessagesController < AdminController
  before_action :require_manager

  def index
    @messages = Message.official_messages.paginate(:page => params[:page])
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      flash[:notice] = "成功新增訊息"
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
    @user = User.find(params[:user_id])
    @messages = @user.messages
  end

  def my_new_message
    @user = User.find(params[:user_id])
    @message = @user.messages.new
  end

  private

  def message_params
    params.require(:message).permit(:title, :content, :message_type, user_ids: [])
  end
end