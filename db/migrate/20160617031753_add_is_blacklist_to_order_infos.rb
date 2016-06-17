class AddIsBlacklistToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :is_blacklist, :boolean
    add_index :order_infos, :is_blacklist
  end
end