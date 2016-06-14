class AddImageToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :image, :string

    remove_column :categories, :status
    remove_column :categories, :deleted_at
  end

  def down
    add_column :categories, :status, :integer, default: 0
    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at

    remove_column :categories, :image
  end
end