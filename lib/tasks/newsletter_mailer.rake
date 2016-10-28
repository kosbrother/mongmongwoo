namespace :newsletter_mailer do
  task :send_edm_newsletter => :environment do
    SendEdmEmailWorker.new.perform
  end
end