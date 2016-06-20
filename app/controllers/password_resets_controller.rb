class PasswordResetsController < ApplicationController
  layout 'password_reset'
  before_action  :load_categories

  def edit
    @password_reset_token = params[:token]
  end

  def update
    user = User.find_by_password_reset_token(params['password_reset_token'])
    if user.nil?
      flash[:danger] = "請檢查網址是否正確或者已經失效"
      redirect_to :back
    else
      user.password = params['password']
      user.password_reset_token = nil
      user.save
      redirect_to  password_resets_success_path
    end
  end
end