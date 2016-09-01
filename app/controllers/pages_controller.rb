class PagesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def index
    @category_with_items = @categories.map { |category| {category: category, items: category.items.on_shelf.priority.latest(12)} }
    set_meta_tags title: '首頁'
  end

  def shop_infos
    @shop_infos = ShopInfo.all
  end
end
