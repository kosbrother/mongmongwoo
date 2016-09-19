class RenameStatusToShoppingPointAmount < ActiveRecord::Migration
  def up
    rename_column :carts, :status, :shopping_point_amount
  end

  def down
    rename_column :carts, :shopping_point_amount , :status
  end
end
