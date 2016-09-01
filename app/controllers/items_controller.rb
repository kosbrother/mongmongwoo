class ItemsController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['category_id'])
    @item = Item.find(params['id'])
    @item.specs.on_shelf.size == 0 ? @specs = @item.specs : @specs = @item.specs.on_shelf

    set_meta_tags title: @item.name,
                  description: @item.description
  end
end
