class Schedule < ActiveRecord::Base
  enum execute_status: { false: 0, true: 1 }

  belongs_to :scheduleable, polymorphic: true
end