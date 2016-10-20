class RemovePromotions < ActiveRecord::Migration
  def change
    drop_table :promotions
    drop_table :item_promotions
  end
end
