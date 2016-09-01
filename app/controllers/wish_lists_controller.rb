class WishListsController < ApplicationController
  layout 'user'

  before_action  :load_categories, :require_user

  def index
    @wish_lists = current_user.wish_lists.includes(:item, :item_spec)
    if @wish_lists.any?
      @category_all = Category.find(10)
    end
    set_meta_tags title: "補貨清單", noindex: true
  end

  def destroy
    @wish_list = current_user.wish_lists.find(params[:id])
    @wish_list.destroy
  end
end