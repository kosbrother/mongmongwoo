class AddCostToItems < ActiveRecord::Migration
  def change
    add_column :items, :cost, :decimal, precision: 10, scale: 2
  end
end