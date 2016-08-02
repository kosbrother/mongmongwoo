class AddStopRecommendToItemSpec < ActiveRecord::Migration
  def change
    add_column :item_specs, :is_stop_recommend, :boolean, default: false
  end
end
