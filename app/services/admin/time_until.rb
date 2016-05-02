class Admin::TimeUntil
  attr_reader :time_param

  TIME_RANGE = {
                  "month" => Range.new((Time.now - 30.day), Time.now),
                  "week" => Range.new((Time.now - 7.day), Time.now),
                  "day" => Range.new((Time.now - 1.day), Time.now)
                }

  def initialize(time_param)
    @time_param = time_param
  end

  def time_within
    TIME_RANGE[self.time_param]
  end
end