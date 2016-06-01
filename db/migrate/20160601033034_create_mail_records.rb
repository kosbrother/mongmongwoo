class CreateMailRecords < ActiveRecord::Migration
  def change
    create_table :mail_records do |t|
      t.integer :recordable_id
      t.string :recordable_type
      t.integer :mail_type
      t.timestamps null: false
    end

    add_index :mail_records, :recordable_id
    add_index :mail_records, :recordable_type
    add_index :mail_records, :mail_type
  end
end