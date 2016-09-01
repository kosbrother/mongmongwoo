class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  helper EmailHelper
  default from: "\"萌萌屋\" <service@mmwooo.com>"
  layout 'mailer'
end