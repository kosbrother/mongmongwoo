class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    Rails.logger.warn("mail to : #{@user.email}")
    mail(to: @user.email, :subject => "[萌萌屋] 重新設置密碼")
  end

  def notify_user_registered(user)
    @user = user
    Rails.logger.warn("mail to : #{@user.email}")
    mail(to: @user.email, :subject => "[萌萌屋] 萌萌屋會員註冊成功")
  end
end