class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :load_categories, :load_popular_items, :current_cart, :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def load_categories
    @categories = Category.except_the_all_category
  end

  def load_popular_items
    @pop_items = Item.joins(:item_categories).order( "item_categories.position asc").limit(6)
    @category_all = Category.find(10)
  end

  def current_cart
    if session[:cart_id] &&  Cart.exists?(session[:cart_id])
      @cart = Cart.find(session[:cart_id])
    else
      create_cart
    end
  end

  def create_cart
    @cart = Cart.create(user_id: current_user ||= 31)
    session[:cart_id] = @cart.id
  end

end
