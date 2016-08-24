class SeedRegisterCampaignToShoppingPointCampaigns < ActiveRecord::Migration
  def up
    shopping_point_campaign = ShoppingPointCampaign.find_or_initialize_by(id: 1)
    shopping_point_campaign.id = 1
    shopping_point_campaign.description = '註冊就送購物金'
    shopping_point_campaign.amount = 50
    shopping_point_campaign.save
  end

  def down
    shopping_point_campaign = ShoppingPointCampaign.find_by(id: 1)
    shopping_point_campaign.destroy! if shopping_point_campaign
  end
end
