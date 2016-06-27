class CreateStockSpecs < ActiveRecord::Migration
  def change
    create_table :stock_specs do |t|
      t.integer :stock_id
      t.integer :item_spec_id
      t.integer :amount
      t.timestamps null: false
    end

    add_index :stock_specs, :stock_id
    add_index :stock_specs, :item_spec_id
  end
end