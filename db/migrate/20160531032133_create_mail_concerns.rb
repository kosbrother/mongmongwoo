class CreateMailConcerns < ActiveRecord::Migration
  def change
    create_table :mail_concerns do |t|
      t.integer :mailable_id
      t.string :mailable_type
      t.boolean :is_sent, default: false
      t.datetime :sent_email_at
      t.timestamps null: false
    end

    add_index :mail_concerns, :mailable_id
    add_index :mail_concerns, :mailable_type
    add_index :mail_concerns, :is_sent
    add_index :mail_concerns, :sent_email_at
  end
end