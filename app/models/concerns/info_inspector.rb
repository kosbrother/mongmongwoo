module InfoInspector
  extend ActiveSupport::Concern

  included do
    after_create :inspec_is_blacklist
  end

  def inspec_is_blacklist
    if has_data_in_blacklist? || invalid_data_format?
      self.update_attribute(:in_blacklist, true)
    end
  end

  private

  def has_data_in_blacklist?
    OrderBlacklist.email_blacklists.include?(self.ship_email) || OrderBlacklist.phone_blacklists.include?(self.ship_phone)
  end

  def invalid_data_format?
    !(OrderBlacklist::Email_Format.match(self.ship_email)) || !(OrderBlacklist::Phone_Format.match(self.ship_phone))
  end
end