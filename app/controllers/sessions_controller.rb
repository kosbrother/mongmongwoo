class SessionsController < ApplicationController

  def login_by_mmw
    user = User.find_by(email: params[:email], is_mmw_registered: true)
    if user && user.authenticate(params[:password])
      set_current_user_and_cart(user)
      render 'partials/js/reload'
    elsif user.nil?
      @message = t('controller.error.message.no_user')
      render 'error'
    else
      @message = t('controller.error.message.wrong_password')
      render 'error'
    end
  end

  def login_by_auth
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)
    set_current_user_and_cart(user) if user

    redirect_to request.env['omniauth.origin']
  end

  def destroy
    session[:user_id] = nil
    current_cart.user_id = User::ANONYMOUS
    current_cart.save

    redirect_to root_path
  end
end
