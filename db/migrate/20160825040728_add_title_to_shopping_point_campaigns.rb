class AddTitleToShoppingPointCampaigns < ActiveRecord::Migration
  def change
    add_column :shopping_point_campaigns, :title, :string
    shopping_point_campaign = ShoppingPointCampaign.find_or_initialize_by(id: ShoppingPointCampaign::REGISTER_ID)
    shopping_point_campaign.title = '註冊就送購物金'
    shopping_point_campaign.save
  end
end
