class GcmNotifyService
  require 'gcm'

  attr_reader :gcm

  def initialize
    @gcm = GCM.new(ENV["GCM_KEY"])
  end

  def send_item_event_notification(options)
    DeviceRegistration.select(:id, :registration_id).find_in_batches do |ids|
      registration_ids = ids.map(&:registration_id)
      @gcm.send_notification(registration_ids, options)
    end
  end

  def send_pickup_notification(registration_id, options)
    @gcm.send(registration_id, options)
  end

  def send_message_notification(registration_id, options)
    @gcm.send(registration_id, options)
  end
end