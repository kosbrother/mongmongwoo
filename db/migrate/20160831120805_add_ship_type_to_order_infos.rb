class AddShipTypeToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :ship_type, :integer
  end
end
