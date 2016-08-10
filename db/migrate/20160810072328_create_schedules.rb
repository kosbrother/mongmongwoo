class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.references :scheduleable, polymorphic: true, index: true
      t.datetime :execute_time
      t.boolean :is_execute, default: false
      t.string :schedule_type
    end
  end
end
