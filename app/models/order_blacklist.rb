class OrderBlacklist < ActiveRecord::Base
  OrderBlacklist::Email_Format = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  OrderBlacklist::Phone_Format = /\A(\+\d{3}-)?(\(?(0)?([2-9])\)?)(-)?(\d{2})?(-)?\d{3,4}(-)?\d{3,4}\z/

  scope :email_blacklists, -> { uniq.map(&:email) }
  scope :phone_blacklists, -> { uniq.map(&:phone) }
end