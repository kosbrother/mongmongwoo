class GcmNotifyService
  require 'gcm'

  attr_reader :gcm

  def initialize
    @gcm = GCM.new(ENV["GCM_KEY"])
  end

  def send_notification(registration_ids, options)
    if registration_ids.size > 1000
      registration_ids.each_slice(1000) do |per_registration_ids|
        @gcm.send_notification(per_registration_ids, options)
      end
    else
      @gcm.send_notification(registration_ids, options)
    end
  end
end