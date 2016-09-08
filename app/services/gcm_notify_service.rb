class GcmNotifyService
  require 'gcm'

  attr_reader :gcm

  def initialize
    @gcm = GCM.new(ENV["GCM_KEY"])
  end

  def send_notification(device_ids, options)
    DeviceRegistration.where(id: device_ids).find_in_batches do |ids|
      registration_ids = ids.map(&:registration_id)
      @gcm.send_notification(registration_ids, options)
    end
  end
end