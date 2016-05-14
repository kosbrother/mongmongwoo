class CreateCostStatistics < ActiveRecord::Migration
  def change
    create_table :cost_statistics do |t|
      t.integer :cost_of_goods, :cost_of_advertising, :cost_of_freight_in
      t.date :cost_date
      t.timestamps null: false
    end
    add_index :cost_statistics, :cost_date
  end
end