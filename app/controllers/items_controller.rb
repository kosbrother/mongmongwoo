class ItemsController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['category_id'])
    @item = Item.find(params['id'])
    @item.specs.on_shelf.size == 0 ? @item_specs = @item.specs : @item_specs = @item.specs.on_shelf
    @first_item_spec = @item_specs.detect{|spec| spec.stock_amount > 0}
    @first_item_spec = @item_specs.first if @first_item_spec.blank?

    set_meta_tags title: @item.name,
                  description: @item.description,
                  og: {
                    title:       @item.name,
                    type:        "product.item",
                    url:         category_item_url(@category, @item),
                    image:       view_context.asset_url(@item.photos.first.image_url),
                    description: view_context.strip_tags(@item.description).gsub("\r\n", " ")
                  }
  end

  def catalog
    @items = Item.on_shelf
  end
  
end
