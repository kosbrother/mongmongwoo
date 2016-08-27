class AddIsRepurchasedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_repurchased, :boolean, default: false
    add_index :orders, :is_repurchased
  end
end
