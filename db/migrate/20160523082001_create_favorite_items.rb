class CreateFavoriteItems < ActiveRecord::Migration
  def change
    create_table :favorite_items do |t|
      t.integer :user_id
      t.integer :item_id

      t.timestamps null: false
    end

    add_index :favorite_items, :user_id
    add_index :favorite_items, :item_id
  end
end
