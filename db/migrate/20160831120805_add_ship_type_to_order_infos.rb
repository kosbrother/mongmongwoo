class AddShipTypeToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :ship_type, :integer, default: 0
  end
end
