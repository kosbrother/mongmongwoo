class RenameRealItemQuantityToActualItemQuantity < ActiveRecord::Migration
  def up
    rename_column :admin_cart_items, :real_item_quantity, :actual_item_quantity
  end

  def down
    rename_column :admin_cart_items, :actual_item_quantity, :real_item_quantity
  end
end
