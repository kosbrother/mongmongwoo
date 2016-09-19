class Admin::ShoppingPointsController < AdminController
  before_action :require_manager
  before_action :find_user, only: [:new, :create]

  def new
    @shopping_point = @user.shopping_points.new
  end

  def create
    @shopping_point = @user.shopping_points.new(shopping_point_params)

    if @shopping_point.save
      flash[:notice] = "成功發送購物金給使用者"
      redirect_to :back
    else
      flash[:danger] = "請檢查購物金內容是否有誤"
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