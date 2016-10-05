class Admin::CampaignRulesController <AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_campaign_rule, only: [:edit, :destroy, :update]

  def index
    @is_valid = params.fetch('is_valid','true')
    @campaign_rules = CampaignRule.includes(:shopping_point_campaign, campaigns: :discountable).where(is_valid: @is_valid == 'true')
  end

  def new
    @campaign_rule = CampaignRule.new
    @campaign_rule.shopping_point_campaign = ShoppingPointCampaign.new
    @campaign_ids = []
  end

  def create
    campaign_rule = CampaignRule.create(campaign_rule_params)

    if campaign_for_order?
      if campaign_rule.discount_type == "shopping_point"
        campaign_rule.update(shopping_point_campaign_params)
      else
        campaign_rule.campaigns.create(discountable_type: nil, discountable_id: nil)
      end
    else
      campaign_rule.campaigns.create(campaign_items_params)
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

    if @campaign_rule.discount_type == "shopping_point"
      @campaign_rule.update(shopping_point_campaign_params)
    end

    redirect_to admin_campaign_rules_path
  end

  private

  def campaign_rule_params
    params.require("campaign_rule").permit(:title, :description, :banner_cover, :card_icon, :list_icon, :rule_type, :threshold, :discount_type, :discount_percentage, :discount_money, :valid_until)
  end

  def campaign_items_params
    hash = params.require("campaign_rule").permit(campaign_items: [])
    hash[:campaign_items].select{|id| id.present?}.map{|id| {discountable_type: 'Item', discountable_id: id}}
  end

  def campaign_for_order?
    params["campaign_rule"]["campaign_for_order"] == 'true'
  end

  def campaign_item_ids
    params.require("campaign_rule").permit(campaign_items: [])['campaign_items'].select{|id| id.present?}.map{|id| id.to_i}
  end

  def shopping_point_campaign_params
    params.require("campaign_rule").permit(shopping_point_campaign_attributes: [:id, :title, :description, :amount, :valid_until, :is_reusable])
  end

  def find_campaign_rule
    @campaign_rule = CampaignRule.find(params[:id])
  end
end