class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :load_categories, :load_popular_items

  def load_categories
    @categories = Category.except_the_all_category
  end

  def load_popular_items
    @pop_items = Item.joins(:item_categories).order( "item_categories.position asc").limit(6)
    @category_all = Category.find(10)
  end

end
