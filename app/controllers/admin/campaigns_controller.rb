class Admin::CampaignsController < AdminController
  before_action do
    accept_role(:manager)
  end

  def destroy
    campaign = Campaign.find(params[:id])
    campaign.destroy
    redirect_to admin_campaign_rules_path
  end
end