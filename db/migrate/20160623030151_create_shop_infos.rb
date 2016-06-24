class CreateShopInfos < ActiveRecord::Migration
  def change
    create_table :shop_infos do |t|
      t.string :question
      t.string :answer

      t.timestamps null: false
    end
  end
end
