class Api::V4::CategoriesController < ApiController
  def index
    categories = Category.parent_categories.select_api_fields

    render status: 200, json: {data: categories.as_json(include: {child_categories: {only: [:id, :name, :image]}})}
  end
end