class CreateItemPromotions < ActiveRecord::Migration
  def change
    create_table :item_promotions do |t|
      t.integer :item_id
      t.integer :promotion_id
      t.date :ending_on
      t.timestamps
    end

    add_index :item_promotions, :item_id
    add_index :item_promotions, :promotion_id
    add_index :item_promotions, :ending_on
  end
end