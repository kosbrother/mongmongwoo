class ChangePositionDefaultValue < ActiveRecord::Migration
  def change
    change_column :item_categories, :position, :integer, default: 1000
  end
end
