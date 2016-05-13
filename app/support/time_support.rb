class TimeSupport
  attr_reader :time_param

  TIME_RANGE = {
    "month" => Range.new((Time.now - 30.day), Time.now),
    "week" => Range.new((Time.now - 7.day), Time.now),
    "day" => Range.new((Time.now - 1.day), Time.now)
  }

  def self.time_until(time_param)
    TIME_RANGE[time_param]
  end

  def self.dynamic_time_until(earlier_titme, later_time)
    Range.new(earlier_titme, later_time)
  end
end