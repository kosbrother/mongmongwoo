class CategoriesController < ApplicationController
  before_action :load_popular_items, :load_categories

  def show
    @category = Category.find(params['id'])
    parent_id = @category.parent_id || @category.id
    @child_categories = Category.where(parent_id: parent_id)
    @sort_options = Item.sort_params.keys.map {|key| [t("models.item.sort_params.#{key}"), key]}
    @items_sort = params[:items_sort] || @sort_options.first[1]
    month_query = []
    if params[:months_ago]
      months_ago = ActiveRecord::Type::Integer.new.type_cast_from_user(params[:months_ago])
      month_query = ["items.created_at > :month_begin AND items.created_at < :month_end",
                     month_begin: Time.current.ago(months_ago.month).beginning_of_month,
                     month_end: Time.current.ago(months_ago.month).end_of_month]
    end
    @items = @category.items.on_shelf.where(month_query).order(Item.sort_params[@items_sort]).paginate(page: params['page'], per_page: 18)
    set_meta_tags title: @category.name,
                  keywords: @category.name
  end
end
