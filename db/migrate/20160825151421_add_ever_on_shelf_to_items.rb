class AddEverOnShelfToItems < ActiveRecord::Migration
  def change
    add_column :items, :ever_on_shelf, :boolean, default: false
    add_index :items, :ever_on_shelf
  end
end
