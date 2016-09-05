class CategoriesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['id'])
    parent_id = @category.parent_id || @category.id
    @child_categories = Category.where(parent_id: parent_id)
    @sort_options = Item.sort_params.keys.map {|key| [t("models.item.sort_params.#{key}"), key]}
    @items_sort = params[:items_sort] || @sort_options.first[1]
    @items = @category.items.on_shelf.order(Item.sort_params[@items_sort]).paginate(page: params['page'], per_page: 18)

    set_meta_tags title: @category.name,
                  keywords: @category.name
  end
end
