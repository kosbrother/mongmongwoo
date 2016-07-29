class AddIsReturnToOrdersAndOrderItems < ActiveRecord::Migration
  def change
    add_column :orders, :is_return, :boolean, default: false
    add_column :order_items, :is_return, :boolean, default: false
  end
end