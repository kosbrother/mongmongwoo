class ItemsController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['category_id'])
    @item = Item.find(params['id'])
  end
end
