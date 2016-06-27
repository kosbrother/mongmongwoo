class AddStatusToAdminCarts < ActiveRecord::Migration
  def change
    add_column :admin_carts, :status, :integer, default: 0
  end
end
