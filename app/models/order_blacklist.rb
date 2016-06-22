class OrderBlacklist < ActiveRecord::Base
  Mobile_Phone_Part = /^(\(?\+?886\)?(\s|-)?9\d{2}|09\d{2})(\s|-)?\d{3}(\s|-)?\d{3}$/
  Local_Phone_Part = /^(\(?\+?886\)?(\s|-)?\(?[2-9]\)?|\(?0?[2-9]\)?)(\s|-)?(\(?\d{4}\)?(\s|-)?\(?\d{4}\)?|\(?\d{3}\)?(\s|-)?\(?\d{4}\)?|\(?\d{4}\)?(\s|-)?\(?\d{3}\)?)$/
  OrderBlacklist::Phone_Format = /#{Mobile_Phone_Part}|#{Local_Phone_Part}/
  OrderBlacklist::Email_Format = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  scope :email_blacklists, -> { uniq.map(&:email) }
  scope :phone_blacklists, -> { uniq.map(&:phone) }
end