class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
      t.string :provider
      t.integer :user_id
      t.string :uid
      t.string :user_name
      t.string :gender
    end
    add_index :logins, :uid
    add_index :logins, :user_id
    add_index :logins, :provider
  end
end
