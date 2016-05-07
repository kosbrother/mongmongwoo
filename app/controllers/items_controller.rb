class ItemsController < ApplicationController
  def show
    @category = Category.find(params['category_id'])
    @item = Item.find(params['id'])
  end
end
