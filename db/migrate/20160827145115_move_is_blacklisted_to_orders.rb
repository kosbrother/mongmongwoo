class MoveIsBlacklistedToOrders < ActiveRecord::Migration
  def up
    remove_column :order_infos, :is_blacklisted
    add_column :orders, :is_blacklisted, :boolean, default: false
    add_index :orders, :is_blacklisted
  end

  def down
    remove_index :orders, :is_blacklisted
    remove_column :orders, :is_blacklisted
    add_column :order_infos, :is_blacklisted, :boolean
  end
end
