class SessionsController < ApplicationController

  def create_by_mmw
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      cart = current_cart
      cart.user = user
      cart.save

      render js: 'window.location.reload();'
    else
      @message = '帳號密碼錯誤，請重新輸入'
      render 'error'
    end
  end

  def create_by_auth
    auth = request.env["omniauth.auth"].extra.raw_info
    user = User.find_or_create_from_omniauth(auth)
    session[:user_id] = user.id
    cart = current_cart
    cart.user = user
    cart.save

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    cart = current_cart
    cart.user_id = User::ANONYMOUS
    cart.save

    redirect_to root_path
  end
end
