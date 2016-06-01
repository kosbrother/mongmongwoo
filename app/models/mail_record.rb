class MailRecord < ActiveRecord::Base
  enum mail_type: { "satisfaction survey" => 0 }

  belongs_to :recordable, polymorphic: true
end