class MoveItemPostionColumnToItemCategory < ActiveRecord::Migration
  def change
    remove_column :items, :position
    add_column :item_categories, :position, :integer, default: 1
    add_index :item_categories, :position
  end
end
