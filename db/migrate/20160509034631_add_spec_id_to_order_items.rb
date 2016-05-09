class AddSpecIdToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :item_spec_id, :integer
    add_index :order_items, :item_spec_id
  end
end
