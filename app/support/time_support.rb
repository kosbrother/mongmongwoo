class TimeSupport
  attr_reader :time_param

  TIME_RANGE = {
    "month" => Range.new((Time.current - 30.day), Time.current),
    "week" => Range.new((Time.current - 7.day), Time.current),
    "day" => Range.new((Time.current - 1.day), Time.current)
  }

  def self.time_until(time_param)
    TIME_RANGE[time_param]
  end

  def self.dynamic_time_until(earlier_titme, later_time)
    Range.new(earlier_titme, later_time)
  end

  def self.within_days(number)
    Time.current.to_date.prev_day(number).beginning_of_day..Time.current.to_date.end_of_day
  end
end