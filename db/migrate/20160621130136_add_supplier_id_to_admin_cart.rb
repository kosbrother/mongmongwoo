class AddSupplierIdToAdminCart < ActiveRecord::Migration
  def change
    add_column :admin_carts, :taobao_supplier_id, :integer
    add_index :admin_carts, :taobao_supplier_id
  end
end
