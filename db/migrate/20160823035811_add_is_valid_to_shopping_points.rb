class AddIsValidToShoppingPoints < ActiveRecord::Migration
  def change
    add_column :shopping_points, :is_valid, :boolean, default: true
    add_index :shopping_points, :is_valid
  end
end
