class Admin::CampaignRulesController <AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_campaign_rule, only: [:edit, :destroy, :update]

  def index
    @campaign_rules = CampaignRule.includes(campaigns: :discountable).joins(:campaigns).where.not(campaigns: {id: nil} ).distinct
  end

  def new
    @campaign_rule = CampaignRule.new
    @campaign_ids = []
  end

  def create
    campaign_rule = CampaignRule.create(campaign_rule_params)
    campaign_rule.campaigns.create(campaign_items_params)
    if has_campaign_order?
      campaign_rule.campaigns.create(discountable_type: nil, discountable_id: nil)
    end
    redirect_to admin_campaign_rules_path
  end

  def destroy
    @campaign_rule.destroy
    redirect_to admin_campaign_rules_path
  end

  def edit
    @campaign_ids = @campaign_rule.campaigns.map(&:discountable_id)
  end

  def update
    @campaign_rule.update(campaign_rule_params)

    campaign_items_params.each do |params|
      @campaign_rule.campaigns.find_or_create_by(params)
    end
    @campaign_rule.campaigns.where(discountable_type: 'Item').each do |campaign|
      if campaign_item_ids.exclude?(campaign.discountable_id)
        campaign.destroy
      end
    end

    if has_campaign_order?
      @campaign_rule.campaigns.find_or_create_by(discountable_type: nil, discountable_id: nil)
    else
      @campaign_rule.campaigns.where(discountable_type: nil).delete_all
    end

    redirect_to admin_campaign_rules_path
  end

  private

  def campaign_rule_params
    params.require("campaign_rule").permit(:description, :rule_type, :threshold, :discount_type, :discount_percentage, :discount_money)
  end

  def campaign_items_params
    hash = params.require("campaign_rule").permit(campaign_items: [])
    hash[:campaign_items].select{|id| id.present?}.map{|id| {discountable_type: 'Item', discountable_id: id}}
  end

  def has_campaign_order?
    params["campaign_rule"]["has_campaign_order"] == 'true'
  end

  def campaign_item_ids
    params.require("campaign_rule").permit(campaign_items: [])['campaign_items'].select{|id| id.present?}.map{|id| id.to_i}
  end

  def find_campaign_rule
    @campaign_rule = CampaignRule.find(params[:id])
  end
end