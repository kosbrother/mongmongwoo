class AdminController < ActionController::Base
  layout "admin"
  protect_from_forgery with: :exception

  helper_method :current_admin, :current_admin_carts

  def accept_role(*role)
    if role.exclude?(current_admin.role.to_sym)
      session[:admin_id] = nil
      flash[:alert] = "當前訪問的頁面, 您不具有所需的管理員權限，請重新登入"
      redirect_to admin_signin_path
    end
  end

  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

  def current_admin_carts
    session[:admin_cart_ids] = [] unless session[:admin_cart_ids]
    AdminCart.where(id: session[:admin_cart_ids]).includes(:taobao_supplier, {admin_cart_items: [{item: :specs}, :item_spec]})
  end

  def current_supplier_cart(supplier_id)
    supplier_cart = current_admin_carts.find_by(taobao_supplier_id: supplier_id.blank? ? nil : supplier_id)
    supplier_cart = create_supplier_cart(supplier_id) unless supplier_cart
    supplier_cart
  end

  private

  def create_supplier_cart(supplier_id)
    admin_cart = AdminCart.create(taobao_supplier_id: supplier_id)
    session[:admin_cart_ids] << admin_cart.id
    admin_cart
  end
end