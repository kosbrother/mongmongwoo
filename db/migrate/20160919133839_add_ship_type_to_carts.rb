class AddShipTypeToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :ship_type, :integer, default: 0
  end
end
