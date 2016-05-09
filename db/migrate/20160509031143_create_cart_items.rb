class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.integer :cart_id
      t.integer :item_id
      t.string :item_spec_id
      t.integer :item_quantity
      t.timestamps null: false
    end

    add_index :cart_items, :cart_id
    add_index :cart_items, :item_id
    add_index :cart_items, :item_spec_id
  end
end
