namespace :shopping_point_camapaigns do
  task :check_valid_until => :environment do
    ShoppingPointCampaign.where(is_expired: false).each do |shopping_point_campaign|
      if shopping_point_campaign.valid_until && shopping_point_campaign.valid_until <= Time.current
        shopping_point_campaign.update_column(:is_expired, true)
      end
    end
  end
end