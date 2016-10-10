class CategoriesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['id'])
    parent_id = @category.parent_id || @category.id
    @child_categories = Category.where(parent_id: parent_id)
    @sort_options = Item.sort_params.keys.map {|key| [t("models.item.sort_params.#{key}"), key]}
    @items_sort = params[:items_sort] || @sort_options.first[1]
    @items = @category.items.on_shelf.order(Item.sort_params[@items_sort]).paginate(page: params['page'], per_page: 18)
    if @category.parent_id
      siblings_name = @child_categories.reject{|c| c.id == @category.id}.map(&:name).join(",")
      meta_description = "「#{@category.name}」類別商品, 周周上新品, 校園生活萌物，APP購物現貨不必等, 萌萌屋是學生的網購天堂。另有相關類別：#{siblings_name}。"
      meta_keywords = @child_categories.map(&:name)
    else
      childs_name = @child_categories.map(&:name).join(",")
      meta_description = "萌萌屋「#{@category.name}」類別商品, 周周上新品, 校園生活萌物，APP購物現貨不必等, 萌萌屋是學生的網購天堂。另有子類別：#{childs_name}。"
      meta_keywords = @child_categories.map(&:name).push(@category.name)
    end

    set_meta_tags title: @category.name,
                  description: meta_description,
                  keywords: meta_keywords,
                  og: {
                    title:       "#{@category.name}-萌萌屋(校園生活補給站)",
                    type:        "product.group",
                    url:         category_url(@category, protocol: 'https'),
                    image:       view_context.asset_url(@category.image_url),
                    description: meta_description
                  }
  end
end
