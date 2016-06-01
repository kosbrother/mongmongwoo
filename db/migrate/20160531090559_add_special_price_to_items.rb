class AddSpecialPriceToItems < ActiveRecord::Migration
  def change
    add_column :items, :special_price, :integer
  end
end
