class Admin::ShoppingPointCampaignsController < AdminController
  before_action :require_manager

  def index
    @is_expired = params[:is_expired] == 'true'
    @shopping_point_campaigns = ShoppingPointCampaign.where(is_expired: @is_expired).order(id: :desc).paginate(:page => params[:page])
  end

  def show
    @shopping_point_campaign = ShoppingPointCampaign.find(params[:id])
  end

  def create
    shopping_point_campaign = ShoppingPointCampaign.new(shopping_point_campaign_params)

    if shopping_point_campaign.save
      flash[:notice] = "成功新增購物金活動"
      redirect_to admin_shopping_point_campaigns_path
    else
      flash[:danger] = "請檢查活動內容是否有誤"
      render :new
    end
  end

  private

  def shopping_point_campaign_params
    params.require(:shopping_point_campaign).permit(:title, :description, :amount, :created_at, :valid_until, :is_reusable)
  end
end
