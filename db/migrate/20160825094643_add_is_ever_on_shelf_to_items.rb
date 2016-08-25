class AddIsEverOnShelfToItems < ActiveRecord::Migration
  def up
    add_column :items, :is_ever_on_shelf, :boolean, default: false
    add_index :items, :is_ever_on_shelf

    Item.all.each do |item|
      if item.specs.on_shelf.any?
        item.update_column(:is_ever_on_shelf, true)
      end
    end
  end

  def down
    remove_column :items, :is_ever_on_shelf
  end
end
