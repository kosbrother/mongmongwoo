class AddRealNameToItemsAndResetStatusDefaultValue < ActiveRecord::Migration
  def up
    change_column_default :items, :status, 1
    add_column :items, :real_name, :string
  end

  def down
    remove_column :items, :real_name
    change_column_default :items, :status, 0
  end
end