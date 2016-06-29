class UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      cart = current_cart
      cart.user = user
      cart.save
    else
      flash[:danger] = '註冊失敗，請重新輸入您的註冊訊息'
    end

    redirect_to root_path
  end

  private

  def user_params
    params.permit(:user_name, :email, :password)
  end
end