class AddTitleToShoppingPointCampaigns < ActiveRecord::Migration
  def change
    add_column :shopping_point_campaigns, :title, :string
  end
end
