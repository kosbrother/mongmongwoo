class UsersController < ApplicationController
  def create
    user = User.find_or_initialize_by(email: params[:email])
    if params[:email].blank?
      @message = '信箱不可為空白'
      render 'register_error'
    elsif params[:password].blank?
      @message = '密碼不可為空白'
      render 'register_error'
    elsif user && user.password_digest
      @message = '信箱已被註冊，請重新輸入'
      render 'register_error'
    elsif user.invalid?
      @message = '信箱格式錯誤，請重新輸入'
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
      @message = '找不到此信箱，請重新輸入'
      render 'forget_error'
    end
  end

  private

  def user_params
    params.permit(:user_name, :email, :password)
  end
end
