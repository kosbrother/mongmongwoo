class AdminController < ActionController::Base
  layout "admin"
  protect_from_forgery with: :exception

  helper_method :current_manager, :manager_logged_in?, :current_admin_cart

  def current_manager
    @current_manager ||= Manager.find_by(remember_token: cookies[:remember_token]) if cookies[:remember_token]
  end

  def manager_logged_in?
    !!current_manager
  end

  def require_manager
    unless manager_logged_in?
      flash[:alert] = "裡面太危險了，趕快回家吧！"
      redirect_to admin_signin_path
    end
  end

  def current_admin_cart
    @cart ||= AdminCart.find(session[:admin_cart_id]) if session[:admin_cart_id]
    @cart = create_admin_cart unless @cart
    @cart
  end

  private

  def create_admin_cart
    admin_cart = AdminCart.create
    session[:admin_cart_id] = admin_cart.id
    admin_cart
  end
end