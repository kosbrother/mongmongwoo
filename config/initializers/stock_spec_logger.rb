class StockSpecLogger < Logger
  include Singleton

  def initialize
    super(Rails.root.join('log/stock_spec.log'), 'daily')
    self.formatter = formatter()
    self
  end

  def formatter
    Proc.new{|severity, time, progname, msg|
      formatted_severity = sprintf("%-5s",severity.to_s)
      formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
      "[#{formatted_severity} #{formatted_time} #{$$}] #{msg.to_s.strip}\n"
    }
  end

  class << self
    delegate :info, :to => :instance
  end
end

StockSpecLogger.info("loading logger")