class Admin::ShoppingPointsController < AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_user

  def index
    params[:is_valid] ||= true
    @shopping_points = @user.shopping_points.includes(:shopping_point_campaign).where(is_valid: params[:is_valid]).recent.paginate(:page => params[:page])
  end

  def new
    @shopping_point = @user.shopping_points.new
    @order = Order.find(params[:order_id]) if params[:order_id]
  end

  def create
    @shopping_point = @user.shopping_points.new(shopping_point_params)

    if @shopping_point.save
      @shopping_point.shopping_point_records.first.update_column(:order_id, params[:order_id]) if params[:order_id]
      flash[:notice] = "成功發送購物金給使用者"
      redirect_to admin_user_shopping_points_path(@user)
    else
      flash[:danger] = "請檢查內容是否有誤"
      render :new
    end
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def shopping_point_params
    params.require(:shopping_point).permit(:point_type, :amount, :valid_until, :shopping_point_campaign_id)
  end
end