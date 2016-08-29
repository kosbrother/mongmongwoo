class RemoveUnusedIndex < ActiveRecord::Migration
  def up
    remove_index :orders, :deleted_at
    remove_index :orders, :device_registration_id
    remove_index :orders, :is_blacklisted
    remove_index :orders, :is_repurchased
  end

  def down
    add_index :orders, :is_repurchased
    add_index :orders, :is_blacklisted
    add_index :orders, :device_registration_id
    add_index :orders, :deleted_at
  end
end
