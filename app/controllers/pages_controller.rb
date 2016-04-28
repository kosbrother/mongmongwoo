class PagesController < ApplicationController

  def index
    categories_id = @categories.select {|c| c.id != 10}.collect { |c| c.id }
    @items = categories_id.map {|id| Item.search_categories_new(id, 6)}
  end

end