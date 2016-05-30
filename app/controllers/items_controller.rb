class ItemsController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['category_id'])
    @item = Item.find(params['id'])
    if current_user && current_user.favorites.exists?(@item)
      @in_favorite = true
    else
      @in_favorite = false
    end
    set_meta_tags title: @item.name,
                  description: @item.description
  end
end
