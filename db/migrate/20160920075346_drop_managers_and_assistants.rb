class DropManagersAndAssistants < ActiveRecord::Migration
  def change
    drop_table :managers
    drop_table :assistants
  end
end
