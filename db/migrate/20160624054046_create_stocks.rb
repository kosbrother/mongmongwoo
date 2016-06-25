class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :name
      t.decimal  :cost, precision: 10, scale: 2
      t.integer  :price
      t.text  :description
      t.string :cover
      t.string  :url
      t.integer  :taobao_supplier_id
      t.timestamps null: false
    end

    add_index :stocks, :taobao_supplier_id
  end
end