class CreateShoppingPointRecords < ActiveRecord::Migration
  def change
    create_table :shopping_point_records do |t|
      t.integer :shopping_point_id
      t.integer :order_id
      t.integer :amount
      t.integer :balance
      t.timestamps
    end

    add_index :shopping_point_records, :shopping_point_id
    add_index :shopping_point_records, :order_id
  end
end
