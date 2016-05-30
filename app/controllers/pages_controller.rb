class PagesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def index
    @category_with_items = @categories.map { |category| {category: category, items: category.items.on_shelf.latest(6)} }
    set_meta_tags title: '首頁'
  end
end
