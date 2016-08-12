class CreateSchedules < ActiveRecord::Migration
  def up
    create_table :schedules do |t|
      t.references :scheduleable, polymorphic: true, index: true
      t.datetime :execute_time
      t.boolean :is_execute, default: false
      t.string :schedule_type
      t.string :job_id
      t.timestamps null: false
    end

    Notification.find_each do |n|
      s = Schedule.new
      s.scheduleable = n
      s.execute_time = n.created_at
      s.is_execute = true
      s.schedule_type = "notify_item"
      s.save
    end
  end

  def down
    drop_table :schedules
  end
end
