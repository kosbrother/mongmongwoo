class CreateAndroidVersion < ActiveRecord::Migration
  def change
    create_table :android_versions do |t|
      t.string :version_name
      t.integer :version_code
      t.text :update_message
    end
  end
end
