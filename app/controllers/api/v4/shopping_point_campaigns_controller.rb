class Api::V4::ShoppingPointCampaignsController < ApiController
  def index
    user = User.find(params[:user_id])
    shopping_point_campaigns = ShoppingPointCampaign.all.as_json(only: [:id, :description, :amount, :valid_until, :is_expired])
    shopping_point_campaigns.each do |shopping_point_campaign|
      if user.shopping_points.find_by(shopping_point_campaign_id: shopping_point_campaign["id"])
        shopping_point_campaign["is_collected"] = true
      else
        shopping_point_campaign["is_collected"] = false
      end
    end

    render status: 200, json: { data: shopping_point_campaigns }
  end
end