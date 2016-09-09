class ChangeItemNoteToText < ActiveRecord::Migration
  def change
    change_column :items, :note, :text, :limit => 65535
  end
end
