class UsersController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user && user.password_digest
      @message = '信箱已被註冊，請重新輸入'
      render 'register_error'
    else
      if user
        user.password = params[:password]
      else
        user = User.new(user_params)
      end
      user.save
      update_user_id(user)
      render js: 'window.location.reload();'
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

  def update_user_id(user)
    session[:user_id] = user.id
    cart = current_cart
    cart.user = user
    cart.save
  end
end