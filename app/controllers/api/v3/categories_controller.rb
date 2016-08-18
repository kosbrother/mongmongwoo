class Api::V3::CategoriesController < ApiController
  def index
    categories = Category.parent_categories.select_api_fields

    render status: 200, json: {data: categories}
  end

  def subcategory
    parent_category = Category.find(params[:id])
    categories = parent_category.child_categories.select_api_fields

    render status: 200, json: {data: categories}
  end
end