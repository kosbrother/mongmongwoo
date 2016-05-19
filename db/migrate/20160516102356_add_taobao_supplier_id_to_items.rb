class AddTaobaoSupplierIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :taobao_supplier_id, :integer
    add_index :items, :taobao_supplier_id
  end
end