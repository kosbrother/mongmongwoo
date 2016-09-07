class AddPositionToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :position, :integer, default: 10
  end
end
