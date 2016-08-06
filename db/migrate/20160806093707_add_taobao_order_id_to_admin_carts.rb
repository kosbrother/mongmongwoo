class AddTaobaoOrderIdToAdminCarts < ActiveRecord::Migration
  def change
    add_column :admin_carts, :taobao_order_id, :string
    add_index :admin_carts, :taobao_order_id
  end
end
