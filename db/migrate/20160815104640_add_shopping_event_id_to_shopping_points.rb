class AddShoppingEventIdToShoppingPoints < ActiveRecord::Migration
  def change
    add_column :shopping_points, :shopping_point_campaign_id, :integer
    add_index :shopping_points, :shopping_point_campaign_id
  end
end
