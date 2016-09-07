class GcmNotifyService
  require 'gcm'

  attr_reader :gcm

  def initialize
    @gcm = GCM.new(ENV["GCM_KEY"])
  end

  def send_notification(registration_ids, options)
    @gcm.send_notification(registration_ids, options)
  end
end