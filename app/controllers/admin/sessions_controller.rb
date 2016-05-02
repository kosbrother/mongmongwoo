class Admin::SessionsController <AdminController
  layout 'signin'

  def new
    redirect_to admin_root_path if current_manager
  end

  def create
    manager = Manager.find_by(email: params[:email])

    if manager && manager.authenticate(params[:password])
      if params[:remember_me]
        # 勾選記住我的話將使用者長久留在使用者瀏覽器
        cookies.permanent[:remember_token] = manager.remember_token
      else
        cookies[:remember_token] = manager.remember_token
      end
      flash[:notice] = "Welcome, #{manager.username}!"
      redirect_to admin_root_path
    else
      flash.now[:alert] = "請確認登入資訊!"
      render :new
    end
  end

  def destroy
    cookies.delete(:remember_token)
    flash[:warning] = "你已經登出了!"
    redirect_to admin_signin_path
  end

end
