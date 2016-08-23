class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.references :bannerable, polymorphic: true, index: true
      t.string :title
      t.string :url
      t.string :image
      t.integer :record_type
      t.timestamps null: false
    end

    add_index :banners, :record_type
  end
end
