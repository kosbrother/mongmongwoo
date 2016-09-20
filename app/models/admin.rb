class Admin < ActiveRecord::Base
  enum role: { manager: 0, staff: 1 }

  has_secure_password
end