class CreateAdminCartItems < ActiveRecord::Migration
  def change
    create_table :admin_cart_items do |t|
      t.integer :admin_cart_id
      t.integer :item_id
      t.integer :item_spec_id
      t.integer :item_quantity

      t.timestamps null: false
    end

    add_index :admin_cart_items, :admin_cart_id
    add_index :admin_cart_items, :item_id
    add_index :admin_cart_items, :item_spec_id
  end
end
