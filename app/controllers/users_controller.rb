class UsersController < ApplicationController
  def create
    user = User.find_or_initialize_by(email: params[:email])
    if params[:email].blank?
      @message = t('controller.error.message.empty_email')
      render 'register_error'
    elsif params[:password].blank?
      @message = t('controller.error.message.empty_password')
      render 'register_error'
    elsif user && user.password_digest
      @message = t('controller.error.message.email_taken')
      render 'register_error'
    elsif user.invalid?
      @message =  t('controller.error.message.wrong_email_format')
      render 'register_error'
    else
      user.password = params[:password]
      user.save
      set_current_user_and_cart(user)
      render 'partials/js/reload'
    end
  end

  def sent_reset_email
    user = User.find_by_email(params[:email])
    if user
      user.sent_password_reset
      render 'sent_reset_email'
    else
      @message = t('controller.error.message.no_user')
      render 'forget_error'
    end
  end

  private

  def user_params
    params.permit(:user_name, :email, :password)
  end
end
