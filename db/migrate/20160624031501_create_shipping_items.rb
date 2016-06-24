class CreateShippingItems < ActiveRecord::Migration
  def change
    create_table :shipping_items do |t|
      t.integer :item_id
      t.integer :item_spec_id
      t.integer :admin_cart_id
      t.integer :item_quantity
      t.boolean :is_checked, default: false
    end

    add_index :shipping_items, :item_id
    add_index :shipping_items, :item_spec_id
    add_index :shipping_items, :admin_cart_id
  end
end
