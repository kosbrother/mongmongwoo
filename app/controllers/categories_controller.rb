class CategoriesController < ApplicationController
  def show
    @items = Item.category_items(params['id']).paginate(page: params['page'], per_page: 18)
    @category = Category.find(params['id'])
  end
end
