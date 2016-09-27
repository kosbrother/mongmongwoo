class Admin::ShoppingPointCampaignsController < AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_shopping_point_campaign, only: [:show, :edit, :update, :expired, :destroy]

  def index
    @is_expired = params[:is_expired] == 'true'
    @shopping_point_campaigns = ShoppingPointCampaign.where(is_expired: @is_expired).order(id: :desc).paginate(:page => params[:page])
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

  def update
    if @shopping_point_campaign.update(shopping_point_campaign_params)
      flash[:notice] = "成功更新購物金活動"
      redirect_to admin_shopping_point_campaigns_path
    else
      flash[:danger] = "請檢查更新內容是否有誤"
      redirect_to :edit
    end
  end

  def destroy
    @shopping_point_campaign.destroy

    redirect_to admin_shopping_point_campaigns_path
  end

  private

  def shopping_point_campaign_params
    params.require(:shopping_point_campaign).permit(:title, :description, :amount, :created_at, :valid_until, :is_reusable)
  end

  def find_shopping_point_campaign
    @shopping_point_campaign = ShoppingPointCampaign.find(params[:id])
  end
end
