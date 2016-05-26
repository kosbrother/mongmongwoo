class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :current_cart


  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
    unless current_user
      flash[:info] = "此功能為會員專屬，請先登入或註冊會員。"
      respond_to do |format|
        format.js { render js: "alert('此功能為會員專屬，請先登入或註冊會員。');" }
        format.html { redirect_to root_path}
      end
    end
  end

  def load_categories
    @categories = Category.except_the_all_category
  end

  def load_popular_items
    @pop_items = Item.joins(:item_categories).on_shelf.order( "item_categories.position asc").limit(6)
    @category_all = Category.find(10)
  end

  def create_cart
    cart = Cart.create(user_id: current_user ? session[:user_id] : 31)
    session[:cart_id] = cart.id
    cart
  end

  def current_cart
    @cart ||= Cart.find(session[:cart_id]) if session[:cart_id]
    @cart = create_cart unless @cart
    @cart
  end

  def total(items)
    items.reduce(0) do |sum, current|
      sum + current.subtotal
    end
  end

  def ship_fee(items)
    if total(items) > Cart::FREE_SHIPPING_PRICE
      0
    else
      Cart::SHIP_FEE
    end
  end

end
