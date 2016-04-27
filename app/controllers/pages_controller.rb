class PagesController < ApplicationController

  def index
    categories_id = @categories.select {|c| c.id != 10}.collect { |c| c.id }
    @items = Item.search_categories_new(categories_id, 6)
  end

end