class AddIsRestockToOrdersAndOrderItems < ActiveRecord::Migration
  def change
    add_column :orders, :is_restock, :boolean, default: false
    add_column :order_items, :is_restock, :boolean, default: false
  end
end