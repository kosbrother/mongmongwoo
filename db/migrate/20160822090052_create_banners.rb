class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.references :bannerable, polymorphic: true, index: true
      t.string :title
      t.string :image
      t.timestamps null: false
    end
  end
end
