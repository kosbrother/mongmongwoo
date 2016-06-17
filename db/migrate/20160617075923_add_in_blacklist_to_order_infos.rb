class AddInBlacklistToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :in_blacklist, :boolean
  end
end