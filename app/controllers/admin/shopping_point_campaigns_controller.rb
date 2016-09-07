class Admin::ShoppingPointCampaignsController < AdminController
  before_action :require_manager

  def index
    @is_expired = params[:is_expired] == 'true'
    @shopping_point_campaigns = ShoppingPointCampaign.where(is_expired: @is_expired).order(id: :desc).paginate(:page => params[:page])
  end

  def show
    @shopping_point_campaign = ShoppingPointCampaign.find(params[:id])
  end
end
