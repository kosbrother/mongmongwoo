class CreateAdditionalPurchaseItems < ActiveRecord::Migration
  def change
    create_table :additional_purchase_items do |t|
      t.integer :item_id, index: true
      t.integer :price
      t.timestamps null: false
    end
  end
end
