class AddRegistrantionIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :registration_id, :string
    add_index :orders, :registration_id
  end
end