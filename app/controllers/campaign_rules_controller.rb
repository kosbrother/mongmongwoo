class CampaignRulesController < ApplicationController
  layout 'user'
  before_action  :load_categories

  def index
    @campaign_rules = CampaignRule.valid
  end

  def show
    @campaign_rule = CampaignRule.find(params[:id])
    @discount_icon_url = @campaign_rule.card_icon.url
    @items = @campaign_rule.items
    @category = Category.find(Category::NEW_ID)
    render :layout => 'campaign'
  end
end