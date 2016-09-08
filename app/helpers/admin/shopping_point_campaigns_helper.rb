module Admin::ShoppingPointCampaignsHelper
  def campaign_valid_date_range(shopping_point_campaign)
    if shopping_point_campaign.valid_until
      display_date_and_time(shopping_point_campaign.created_at) + ' ~ ' + display_date_and_time(shopping_point_campaign.valid_until)
    else
      display_date_and_time(shopping_point_campaign.created_at) + ' ~ 無截止日期'
    end
  end
end