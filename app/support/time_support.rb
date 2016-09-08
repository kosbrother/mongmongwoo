class TimeSupport
  attr_reader :time_param

  def self.time_until(time_param)
    case time_param
    when "month"
      Range.new((Time.current - 30.day), Time.current)
    when "week"
      Range.new((Time.current - 7.day), Time.current)
    when "day"
      Range.new((Time.current - 1.day), Time.current)
    when "day_by_midnight"
      Range.new((Time.current - 1.day).beginning_of_day,(Time.current - 1.day).end_of_day)
    end
  end

  def self.within_days(number)
    (Time.current - number.days)..Time.current
  end

end