class ShoppingPointCampaignsController < ApplicationController
  layout 'user'

  before_action  :load_categories

  def index
    user = current_user || User.find(User::ANONYMOUS)
    ids = user.shopping_points.map(&:shopping_point_campaign_id)
    @shopping_point_campaigns = ShoppingPointCampaign.order(id: :desc).map do |shopping_point_campaign|
      if ids.include?(shopping_point_campaign.id)
        is_collected = true
      else
        is_collected = false
      end
      [shopping_point_campaign, is_collected]
    end
  end
end