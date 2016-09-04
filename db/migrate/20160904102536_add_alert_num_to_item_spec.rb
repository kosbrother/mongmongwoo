class AddAlertNumToItemSpec < ActiveRecord::Migration
  def change
    add_column :item_specs, :alert_stock_num, :integer, default: 1
  end
end
