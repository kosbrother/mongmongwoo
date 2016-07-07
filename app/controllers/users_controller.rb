class UsersController < ApplicationController
  def create
    register = User.register(params[:email], params[:password])
    if register[:result]
      set_current_user_and_cart(register[:user])
      render 'partials/js/reload'
    else
      @message =  register[:message]
      render 'register_error'
    end
  end

  def sent_reset_email
    user = User.find_by(email: params[:email], is_mmw_registered: true)
    if user
      user.sent_password_reset
      render 'sent_reset_email'
    else
      @message = t('controller.error.message.no_user')
      render 'forget_error'
    end
  end
end
