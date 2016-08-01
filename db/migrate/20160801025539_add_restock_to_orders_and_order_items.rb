class AddRestockToOrdersAndOrderItems < ActiveRecord::Migration
  def change
    add_column :orders, :restock, :boolean, default: false
    add_column :order_items, :restock, :boolean, default: false
  end
end