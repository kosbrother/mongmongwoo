class AddNoteToAdminCarts < ActiveRecord::Migration
  def change
    add_column :admin_carts, :note, :string
  end
end
