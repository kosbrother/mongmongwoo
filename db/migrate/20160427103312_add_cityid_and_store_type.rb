class AddCityidAndStoreType < ActiveRecord::Migration
  def change
    add_column :counties, :cityid, :string
    add_column :counties, :store_type, :integer
    add_index :counties, :cityid
    add_index :counties, :store_type

    add_column :towns, :store_type, :integer
    add_index :towns, :store_type

    add_column :roads, :store_type, :integer
    add_index :roads, :store_type
  end
end