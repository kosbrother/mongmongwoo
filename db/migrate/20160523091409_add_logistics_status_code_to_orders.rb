class AddLogisticsStatusCodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :logistics_status_code, :integer
    add_index :orders, :logistics_status_code
  end
end