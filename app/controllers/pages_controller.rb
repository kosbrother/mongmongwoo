class PagesController < ApplicationController

  def index
    @items = @categories.map { |category| [category, category.items.category_new(6)] }
  end

end