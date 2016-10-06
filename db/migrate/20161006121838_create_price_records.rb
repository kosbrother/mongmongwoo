class CreatePriceRecords < ActiveRecord::Migration
  def change
    create_table :price_records do |t|
      t.integer :item_id
      t.integer :price
      t.integer :special_price
      t.datetime :changed_at
    end
    Item.all.each do |item|
      pr = PriceRecord.new
      pr.item = item
      pr.changed_at = item.created_at
      pr.price = item.price
      pr.special_price = item.special_price
      pr.save
    end
  end
end
