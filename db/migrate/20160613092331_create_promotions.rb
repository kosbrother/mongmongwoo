class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :title
      t.string :content
      t.decimal :discount, precision: 10, scale: 2
      t.timestamps
    end
  end
end