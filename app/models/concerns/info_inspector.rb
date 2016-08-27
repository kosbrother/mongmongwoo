module InfoInspector
  extend ActiveSupport::Concern

  included do
    after_save :set_blacklisted_by_checking_order_info, :set_is_repurchased_by_checking_order_info
  end

  def set_blacklisted_by_checking_order_info
    if has_data_in_blacklist? || invalid_data_format?
      order.update_column(:is_blacklisted, true) if order
    end
  end

  def set_is_repurchased_by_checking_order_info
    if is_repurchased_order_info?
      order.update_column(:is_repurchased, true) if order
    end
  end

  private

  def has_data_in_blacklist?
    OrderBlacklist.email_blacklists.include?(ship_email) || OrderBlacklist.phone_blacklists.include?(ship_phone)
  end

  def invalid_data_format?
    !(OrderBlacklist::Email_Format.match(ship_email)) || !(OrderBlacklist::Phone_Format.match(ship_phone))
  end

  def is_repurchased_order_info?
    infos = OrderInfo.where('ship_email = :ship_email OR ship_phone = :ship_phone', ship_email: ship_email, ship_phone: ship_phone)
    infos.count > 1
  end
end