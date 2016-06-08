class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message_type
      t.string :title
      t.text :content
      t.timestamps
    end

    add_index :messages, :message_type
  end
end