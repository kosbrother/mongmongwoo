class RemoveOrderUnusedColumn < ActiveRecord::Migration
  def change
    remove_column :orders, :is_paid
    remove_column :orders, :payment_method
    remove_column :orders, :token
    remove_column :orders, :created_on
  end
end
