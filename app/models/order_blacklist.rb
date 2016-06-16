class OrderBlacklist < ActiveRecord::Base
  scope :email_blacklists, -> { uniq.map(&:email) }
  scope :phone_blacklists, -> { uniq.map(&:phone) }
end