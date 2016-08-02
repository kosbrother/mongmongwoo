class AddTypeToFavoriteItems < ActiveRecord::Migration
  def change
    add_column :favorite_items, :favorite_type, :integer, default: 0
    add_column :favorite_items, :item_spec_id, :integer
    add_column :favorite_items, :deleted_at, :datetime

    add_index :favorite_items, :favorite_type
    add_index :favorite_items, :item_spec_id
  end
end
