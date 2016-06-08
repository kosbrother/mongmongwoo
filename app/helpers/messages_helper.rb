module MessagesHelper
  def display_date(time)
    time.strftime("%Y-%m-%d %H:%M:%S")
  end
end