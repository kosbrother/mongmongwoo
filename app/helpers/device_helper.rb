module DeviceHelper
  def mobile?
    request.user_agent =~ /Android|iPhone/i
  end

  def android?
    request.user_agent =~ /Android/i
  end
end