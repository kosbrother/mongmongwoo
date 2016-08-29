class TimeSupport
  attr_reader :time_param

  TIME_RANGE = {
    "month" => Range.new((Time.current - 30.day), Time.current),
    "week" => Range.new((Time.current - 7.day), Time.current),
    "day" => Range.new((Time.current - 1.day), Time.current),
    "day_by_midnight" => Range.new((Time.current - 1.day).midnight, Time.current.midnight)
  }

  def self.time_until(time_param)
    TIME_RANGE[time_param]
  end

  def self.dynamic_time_until(earlier_titme, later_time)
    Range.new(earlier_titme, later_time)
  end

  def self.within_days(number)
    (Time.current - number.days)..Time.current
  end
end