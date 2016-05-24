class FavoriteItemsController < ApplicationController
  layout 'user'

  before_action  :load_categories

  def index
    @items = current_user.favorites
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
