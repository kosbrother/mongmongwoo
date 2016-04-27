class ApplicationController < ActionController::Base

  before_filter :load_categories, :load_popular_items

  def load_categories
    @categories = Category.all
  end

  def load_popular_items
    @pop_items = Item.joins(:item_categories).order( "item_categories.position asc").limit(6)
  end
end
