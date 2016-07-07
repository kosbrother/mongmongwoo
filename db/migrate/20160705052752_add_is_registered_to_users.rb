class AddIsRegisteredToUsers < ActiveRecord::Migration
  def up
    add_column :users, :is_mmw_registered, :boolean, default: false

    User.all.each do |u|
      if u.password_digest
        u.update_attribute :is_mmw_registered, true
      end
    end
  end

  def down
    remove_column :users, :is_mmw_registered
  end
end
