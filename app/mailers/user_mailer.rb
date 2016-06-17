class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    Rails.logger.warn("mail to : #{@user.email}")
    mail(to: @user.email, :subject => "[萌萌屋] 重新設置密碼")
  end
end