class Api::V3::CategoriesController < ApiController
  def index
    categories = Category.id_and_name

    render json: categories
  end
end