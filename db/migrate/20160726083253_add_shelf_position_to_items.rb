class AddShelfPositionToItems < ActiveRecord::Migration
  def change
    add_column :items, :shelf_position, :string
    add_column :item_specs, :shelf_position, :string
    spec_position_array = ItemSpec::SHELF_POSITION
    Item.all.each do |item|
      item.specs.each_with_index do |spec, index|
        spec.shelf_position = spec_position_array[index]
        spec.save
      end
    end
  end
end
