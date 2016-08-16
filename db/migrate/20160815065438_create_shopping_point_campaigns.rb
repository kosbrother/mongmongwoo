class CreateShoppingPointCampaigns < ActiveRecord::Migration
  def change
    create_table :shopping_point_campaigns do |t|
      t.string :description
      t.integer :amount
      t.date :valid_until
      t.boolean :is_expired, default: false
      t.timestamps
    end

    add_index :shopping_point_campaigns, :is_expired
    add_index :shopping_point_campaigns, :valid_until
  end
end
