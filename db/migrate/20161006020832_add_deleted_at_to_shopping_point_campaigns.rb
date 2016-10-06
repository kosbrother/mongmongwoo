class AddDeletedAtToShoppingPointCampaigns < ActiveRecord::Migration
  def change
    add_column :shopping_point_campaigns, :deleted_at, :datetime
  end
end
