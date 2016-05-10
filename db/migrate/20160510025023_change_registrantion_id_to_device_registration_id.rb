class ChangeRegistrantionIdToDeviceRegistrationId < ActiveRecord::Migration
  def up
    remove_column :orders, :registration_id

    add_column :orders, :device_registration_id, :integer
    add_index :orders, :device_registration_id
  end

  def down
    remove_column :orders, :device_registration_id

    add_column :orders, :registration_id, :string
    add_index :orders, :registration_id
  end
end