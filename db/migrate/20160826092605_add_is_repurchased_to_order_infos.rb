class AddIsRepurchasedToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :is_repurchased, :boolean, default: false
    add_index :order_infos, :is_repurchased
  end
end
