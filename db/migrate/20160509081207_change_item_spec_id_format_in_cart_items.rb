class ChangeItemSpecIdFormatInCartItems < ActiveRecord::Migration
  def change
    change_column :cart_items, :item_spec_id, :integer
  end
end
