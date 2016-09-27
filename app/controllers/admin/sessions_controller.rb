class Admin::SessionsController <AdminController
  layout 'signin'

  def new
    redirect_to admin_root_path if current_admin
  end

  def create
    admin = Admin.find_by(username: params[:username])
    if admin && admin.authenticate(params[:password])
      session[:admin_id] = admin.id
      flash[:success] = "Welcome, #{admin.username}!"
      redirect_to admin_root_path
    else
      flash[:warning] = "帳號或密碼錯誤"
      render :new
    end
  end

  def destroy
    session[:admin_id] = nil
    flash[:success] = "你已經登出了!"
    redirect_to admin_signin_path
  end
end
