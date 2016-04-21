class ChangeNoteDefault < ActiveRecord::Migration
  def change
    change_column_default :orders, :note, ""
  end
end
