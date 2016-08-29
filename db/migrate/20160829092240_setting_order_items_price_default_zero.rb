class SettingOrderItemsPriceDefaultZero < ActiveRecord::Migration
  def up
    change_column_default :orders, :items_price, 0
  end

  def down
    change_column_default :orders, :items_price, nil
  end
end
