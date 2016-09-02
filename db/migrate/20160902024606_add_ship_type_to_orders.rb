class AddShipTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ship_type, :integer, default: 0
  end
end
