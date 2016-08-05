class SetAmountDefaultValueToStockSpecs < ActiveRecord::Migration
  def up
    change_column_default :stock_specs, :amount, 0
  end

  def down
    change_column_default :stock_specs, :amount, nil
  end
end