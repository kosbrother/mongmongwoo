class RemoveNoteFromShoppingPoints < ActiveRecord::Migration
  def up
    remove_column :shopping_points, :note
  end

  def down
    add_column :shopping_points, :note, :string
  end
end
