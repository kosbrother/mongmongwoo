class RemoveUnusedColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :real_name
    remove_column :users, :address
    remove_column :users, :phone
  end
end
