class AddCategoryIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :category_id, :integer
    add_index :notifications, :category_id
  end
end