class PagesController < ApplicationController

  def index
    @category_with_items = @categories.map { |category| {category: category, items: category.items.category_new(6)} }
  end

end