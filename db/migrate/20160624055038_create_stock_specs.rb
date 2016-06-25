class CreateStockSpecs < ActiveRecord::Migration
  def change
    create_table :stock_specs do |t|
      t.integer :stock_id
      t.string :style
      t.integer :style_amount
      t.string :style_pic
      t.timestamps null: false
    end

    add_index :stock_specs, :stock_id
  end
end