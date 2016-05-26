class AddSlugToItem < ActiveRecord::Migration
  def change
    add_index :items, :slug, unique: true
  end
end
