class AddDeleteAtToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :deleted_at, :datetime
    add_index :order_items, :deleted_at
  end
end
