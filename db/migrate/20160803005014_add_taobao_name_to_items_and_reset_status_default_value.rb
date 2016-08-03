class AddTaobaoNameToItemsAndResetStatusDefaultValue < ActiveRecord::Migration
  def up
    change_column_default :items, :status, 1
    add_column :items, :taobao_name, :string
  end

  def down
    remove_column :items, :taobao_name
    change_column_default :items, :status, 0
  end
end