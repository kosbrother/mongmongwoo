class FavoriteItemsController < ApplicationController
  layout 'user'

  before_action  :load_categories, :require_user

  def index
    @items = current_user.favorites
    if @items.any?
      @category_all = Category.find(10)
    end
    set_meta_tags title: "我的收藏", noindex: true
  end

  def favorite
    @item = Item.find(params[:id])
    @type = params[:type]
    case @type
    when 'favorite'
      current_user.favorites << @item
    when 'un-favorite'
      current_user.favorites.destroy(@item)
    end
  end

  def remove
    @item = Item.find(params[:id])
    current_user.favorites.destroy(@item)
  end
end
