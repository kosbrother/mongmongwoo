class SetItemQuantityDefaultValueToAdminCartItems < ActiveRecord::Migration
  def up
    change_column_default :admin_cart_items, :item_quantity, 0
  end

  def down
    change_column_default :admin_cart_items, :item_quantity, nil
  end
end
