class StaffController < ActionController::Base
  layout "staff"
  protect_from_forgery with: :exception

  helper_method :current_assistant, :assistant_logged_in?

  def current_assistant
    @current_assistant ||= Assistant.find(session[:assistant_id]) if session[:assistant_id]
  end

  def assistant_logged_in?
    !!current_assistant
  end

  def require_assistant
    unless assistant_logged_in?
      flash[:alert] = "裡面太危險了，趕快回家吧！"
      redirect_to staff_signin_path
    end
  end
end