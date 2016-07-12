class AddOrderedOnAndConfirmedOnToAdminCarts < ActiveRecord::Migration
  def change
    add_column :admin_carts, :ordered_on, :date
    add_column :admin_carts, :confirmed_on, :date
  end
end