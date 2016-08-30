class AddShipTypeAndZipCodeToOrderInfos < ActiveRecord::Migration
  def change
    add_column :order_infos, :ship_type, :integer
    add_column :order_infos, :zip_code, :string
  end
end
