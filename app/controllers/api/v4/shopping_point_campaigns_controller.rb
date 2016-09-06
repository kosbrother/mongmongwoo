class Api::V4::ShoppingPointCampaignsController < ApiController
  def index
    user = User.find(params[:user_id])
    ids = user.shopping_points.map(&:shopping_point_campaign_id)
    shopping_point_campaigns = ShoppingPointCampaign.order(id: :desc).as_json(only: [:id, :title, :description, :amount, :created_at, :valid_until, :is_expired, :is_reusable])
    shopping_point_campaigns.each do |shopping_point_campaign|
      if ids.include?(shopping_point_campaign["id"])
        shopping_point_campaign["is_collected"] = true
      else
        shopping_point_campaign["is_collected"] = false
      end
    end

    render status: 200, json: { data: shopping_point_campaigns }
  end
end