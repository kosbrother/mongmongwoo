class OrderBlacklist < ActiveRecord::Base
  OrderBlacklist::Email_Format = /\A[a-z0-9._%+]+@[a-z0-9.]+\.[a-z]{2,4}\Z/i
  OrderBlacklist::Phone_Format = /\A(0)(9)+\d{8}\Z/

  scope :email_blacklists, -> { uniq.map(&:email) }
  scope :phone_blacklists, -> { uniq.map(&:phone) }
end