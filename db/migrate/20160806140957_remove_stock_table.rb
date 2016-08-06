class RemoveStockTable < ActiveRecord::Migration
  def change
    add_column :stock_specs, :item_id, :integer
    add_index :stock_specs, :item_id
    StockSpec.find_each do |s|
      s.update_column(:item_id,s.stock.item_id)
    end
    drop_table :stocks
    remove_column :stock_specs, :stock_id
  end
end
