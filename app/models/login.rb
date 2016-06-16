class Login < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :uid, :provider
end
