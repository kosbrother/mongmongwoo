class Admin::NotificationsController < AdminController
  before_action :require_manager
  before_action :find_notification, only: [:show]

  def index
    @notifications = Notification.includes(:item).with_schedule.by_execute(params[:is_execute]).recent.paginate(page: params[:page])
  end

  def show
    @item = @notification.item
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      schedule = Schedule.create(scheduleable: @notification, execute_time: params[:execute_time], schedule_type: @notification.schedule_type)
      @notification.put_in_schedule
      flash[:notice] = "成功加入推播排程"
      redirect_to admin_notifications_path(is_execute: Schedule.execute_statuses[:false])
    else
      flash.now[:alert] = "請確認訊息內容"
      render :new
    end
  end

  def get_items
    category = Category.find(params[:category_id])
    items_list = category.items.on_shelf.order("id")
    render json: items_list
  end

  private

  def notification_params
    params.require(:notification).permit(:item_id, :content_title, :content_text, :content_pic, :category_id)
  end

  def find_notification
    @notification = Notification.includes(:item).with_schedule.find(params[:id])
  end
end