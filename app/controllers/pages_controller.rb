class PagesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def index
    @category_with_items = @categories.map { |category| {category: category, items: category.items.category_new(6)} }
  end

end
