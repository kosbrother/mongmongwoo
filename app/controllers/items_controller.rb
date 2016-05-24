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
  end

  def favorite
    @item = Item.find(params[:id])
    type = params[:type]
    case type
    when 'favorite'
      current_user.favorites << @item
    when 'un-favorite'
      current_user.favorites.destroy(@item)
    end
    render nothing: true
  end
end
