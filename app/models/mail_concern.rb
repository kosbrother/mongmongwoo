class MailConcern < ActiveRecord::Base
  belongs_to :mailable, polymorphic: true

  after_update :send_satisfaction_survey_if_pickup

  private

  def send_satisfaction_survey_if_pickup
    if (is_sent && sent_email_at)
      email_to_satisfaction_survey
    end
  end

  def email_to_satisfaction_survey
    OrderMailer.delay.satisfaction_survey(self.mailable)
  end
end