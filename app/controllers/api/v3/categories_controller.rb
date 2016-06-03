class Api::V3::CategoriesController < ApiController
  def index
    categories = Category.select_api_fields

    render json: categories
  end
end