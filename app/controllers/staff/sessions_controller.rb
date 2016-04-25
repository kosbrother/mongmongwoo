class Staff::SessionsController < StaffController
  layout 'signin'

  def new
    redirect_to staff_root_path if current_assistant
  end

  def create
    assistant = Assistant.find_by(email: params[:email])

    if assistant && assistant.authenticate(params[:password])
      session[:assistant_id] = assistant.id
      flash[:notice] = "Welcome, #{assistant.username}!"
      redirect_to staff_root_path
    else
      flash.now[:alert] = "請確認登入資訊喔!"
      render :new
    end
  end

  def destroy
    session[:assistant_id] = nil
    flash[:warning] = "你已經登出了!"
    redirect_to staff_signin_path
  end

end
