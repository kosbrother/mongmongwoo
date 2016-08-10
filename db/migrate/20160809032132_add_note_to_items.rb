class AddNoteToItems < ActiveRecord::Migration
  def change
    add_column :items, :note, :string
  end
end
