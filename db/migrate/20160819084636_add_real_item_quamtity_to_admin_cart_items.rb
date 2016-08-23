class AddRealItemQuamtityToAdminCartItems < ActiveRecord::Migration
  def up
    add_column :admin_cart_items, :real_item_quantity, :integer, default: 0

    AdminCartItem.all.each do |i|
      i.real_item_quantity = i.item_quantity
      i.save
    end
  end

  def down
    remove_column :admin_cart_items, :real_item_quantity
  end
end
