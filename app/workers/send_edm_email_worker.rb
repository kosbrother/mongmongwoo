class SendEdmEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    User.where.not(email: nil).find_each(batch_size: 200) do |user|
      NewsletterMailer.delay.edm_newsletter(user.id)
    end
  end
end