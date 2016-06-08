class CreateMessageRecords < ActiveRecord::Migration
  def change
    create_table :message_records do |t|
      t.integer :user_id
      t.integer :message_id
      t.timestamps
    end

    add_index :message_records, :user_id
    add_index :message_records, :message_id
  end
end