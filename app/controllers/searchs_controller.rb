class  SearchsController < ApplicationController
  before_action :load_popular_items, :load_categories

  def search_items
    @category = Category.find(Category::ALL_ID)
    @items =  Item.select(:id, :name, :price, :special_price, :cover, :slug).search_name_and_description(params[:query]).page(params[:page]).per_page(18).records
  end
end
