class CreateShoppingPoints < ActiveRecord::Migration
  def change
    create_table :shopping_points do |t|
      t.integer :user_id
      t.integer :point_type
      t.integer :amount, null: false, default: 0
      t.date :valid_until
      t.string :note
      t.timestamps
    end

    add_index :shopping_points, :user_id
    add_index :shopping_points, :point_type
  end
end
