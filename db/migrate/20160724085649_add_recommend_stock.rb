class AddRecommendStock < ActiveRecord::Migration
  def change
    add_column :item_specs, :recommend_stock_num, :integer, default: 3
  end
end
