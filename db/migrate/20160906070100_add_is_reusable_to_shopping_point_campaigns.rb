class AddIsReusableToShoppingPointCampaigns < ActiveRecord::Migration
  def change
    add_column :shopping_point_campaigns, :is_reusable, :boolean, default: false
  end
end
