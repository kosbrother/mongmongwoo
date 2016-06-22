class CreateOrderBlacklists < ActiveRecord::Migration
  def change
    create_table :order_blacklists do |t|
      t.string :email
      t.string :phone
      t.timestamps
    end

    add_index :order_blacklists, :email
    add_index :order_blacklists, :phone
  end
end