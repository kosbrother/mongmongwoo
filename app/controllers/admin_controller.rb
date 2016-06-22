class AdminController < ActionController::Base
  layout "admin"
  protect_from_forgery with: :exception

  helper_method :current_manager, :manager_logged_in?, :current_admin_carts

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

  def current_admin_carts
    session[:admin_cart_ids].blank? ? [] : AdminCart.where(id: session[:admin_cart_ids]).includes(:taobao_supplier, {admin_cart_items: [{item: :specs}, :item_spec]})
  end

  def current_supplier_cart(supplier_id)
    supplier_id = supplier_id.to_i
    if current_admin_carts.any?
      supplier_cart = current_admin_carts.select{|cart| cart.taobao_supplier_id == supplier_id}[0]
      supplier_cart = create_supplier_cart(supplier_id) unless supplier_cart
      supplier_cart
    else
      create_supplier_cart(supplier_id)
    end
  end

  private

  def create_supplier_cart(supplier_id)
    admin_cart = AdminCart.create(taobao_supplier_id: supplier_id)
    session[:admin_cart_ids] = [] unless session[:admin_cart_ids]
    session[:admin_cart_ids] << admin_cart.id
    admin_cart
  end
end