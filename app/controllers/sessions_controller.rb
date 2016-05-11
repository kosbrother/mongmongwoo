class SessionsController < ApplicationController


  def create
    auth = request.env["omniauth.auth"].extra.raw_info
    user = User.find_or_create_from_omniauth(auth)
    session[:user_id] = user.id
    @cart.user = user
    @cart.save!

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    @cart.user = User.find(31)
    @cart.save!

    redirect_to root_path
  end
end
