class AddMessageableTypeToMessages < ActiveRecord::Migration
  def up
    change_table :messages do |t|
      t.references :messageable, polymorphic: true, index: true
    end
  end

  def down
    change_table :messages do |t|
      t.remove_references :messageable, polymorphic: true, index: true
    end
  end
end
