class ApplicationController < ActionController::Base

  before_filter :load_categories, :load_popular_items

  def load_categories
    @categories = Category.all
  end

  def load_popular_items
    @pop_items = Item.order(position: :asc).limit(5)
  end
end
