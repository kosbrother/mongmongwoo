class SessionsController < ApplicationController

  def login_by_mmw
    user = User.find_by_email(params[:email])
    if user && user.password_digest && user.authenticate(params[:password])
      set_current_user_and_cart(user)

      render js: 'window.location.reload();'
    else
      @message = '帳號密碼錯誤，請重新輸入'
      render 'error'
    end
  end

  def login_by_auth
    auth = request.env["omniauth.auth"].extra.raw_info
    user = User.find_or_create_from_omniauth(auth)
    set_current_user_and_cart(user)

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    current_cart.user_id = User::ANONYMOUS
    current_cart.save

    redirect_to root_path
  end
end
