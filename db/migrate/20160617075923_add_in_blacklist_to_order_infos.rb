class AddInBlacklistToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :is_blacklisted, :boolean
  end
end