module InfoInspector
  extend ActiveSupport::Concern

  included do
    after_save :set_blacklisted_by_checking_info
  end

  def set_blacklisted_by_checking_info
    if has_data_in_blacklist? || invalid_data_format?
      self.update_column(:is_blacklisted, true)
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