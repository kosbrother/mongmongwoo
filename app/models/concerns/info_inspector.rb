module InfoInspector
  extend ActiveSupport::Concern

  included do
    after_create :inspec_is_blacklist
  end

  def inspec_is_blacklist
    if is_in_blacklist? || is_invalid_data_format?
      self.update_attribute(:is_blacklist, true)
    end
  end

  private

  def is_in_blacklist?
    OrderBlacklist.email_blacklists.include?(self.ship_email) || OrderBlacklist.phone_blacklists.include?(self.ship_phone)
  end

  def is_invalid_data_format?
    !(OrderBlacklist::Email_Format.match(self.ship_email)) || !(OrderBlacklist::Phone_Format.match(self.ship_phone))
  end
end