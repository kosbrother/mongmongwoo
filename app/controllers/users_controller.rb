class UsersController < ApplicationController
  def create
    user = User.find_or_initialize_by(email: params[:email])
    if user.password_digest
      @message = '信箱已被註冊，請重新輸入'
      render 'register_error'
    else
      user.password = params[:password]
      if user.save
        set_current_user_and_cart(user)
        render 'partials/js/reload'
      else
        @message = '信箱格式錯誤，請重新輸入'
        render 'register_error'
      end
    end
  end

  def sent_reset_email
    user = User.find_by_email(params[:email])
    if user
      user.sent_password_reset
      render 'sent_reset_email'
    else
      @message = '找不到此信箱，請重新輸入'
      render 'forget_error'
    end
  end

  private

  def user_params
    params.permit(:user_name, :email, :password)
  end
end
