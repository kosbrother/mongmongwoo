class ApplicationMailer < ActionMailer::Base
  default from: "\"萌萌屋\" <service@kosbrother.com>", css: :admin
  layout 'mailer'
end