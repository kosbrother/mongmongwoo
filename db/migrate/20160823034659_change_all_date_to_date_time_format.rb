class ChangeAllDateToDateTimeFormat < ActiveRecord::Migration
  def up
    change_column :shopping_points, :valid_until, :datetime
    change_column :shopping_point_campaigns, :valid_until, :datetime
    change_column :admin_carts, :ordered_on, :datetime
    change_column :admin_carts, :confirmed_on, :datetime
  end

  def down
    change_column :shopping_points, :valid_until, :date
    change_column :shopping_point_campaigns, :valid_until, :date
    change_column :admin_carts, :ordered_on, :date
    change_column :admin_carts, :confirmed_on, :date
  end
end
