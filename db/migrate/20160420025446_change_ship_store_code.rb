class ChangeShipStoreCode < ActiveRecord::Migration
  def up
    change_column :order_infos, :ship_store_code, :string
  end

  def down
    change_column :order_infos, :ship_store_code, :integer
  end
end