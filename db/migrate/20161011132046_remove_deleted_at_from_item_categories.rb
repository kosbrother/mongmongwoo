class RemoveDeletedAtFromItemCategories < ActiveRecord::Migration
  def change
    remove_column :item_categories, :deleted_at
  end
end
