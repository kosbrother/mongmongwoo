class CategoriesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['id'])
    @items = @category.items.on_shelf.priority.paginate(page: params['page'], per_page: 18)
    parent_id = @category.parent_id || @category.id
    @child_categories = Category.where(parent_id: parent_id)

    set_meta_tags title: @category.name,
                  keywords: @category.name
  end
end
