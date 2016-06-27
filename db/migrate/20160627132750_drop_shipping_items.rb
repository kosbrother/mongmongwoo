class DropShippingItems < ActiveRecord::Migration
  def change
    drop_table :shipping_items do |t|
      t.integer :item_id
      t.integer :item_spec_id
      t.integer :admin_cart_id
      t.integer :item_quantity
      t.boolean :is_checked, default: false
    end
  end
end
