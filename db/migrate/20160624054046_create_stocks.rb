class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :item_id
      t.timestamps null: false
    end

    add_index :stocks, :item_id
  end
end