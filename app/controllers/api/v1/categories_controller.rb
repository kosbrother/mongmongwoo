class Api::V1::CategoriesController < ApiController
  def index
    categories = Category.parent_categories

    render json: categories, only: [:id, :name]
  end

  def show
    category = Category.includes(:items).find(params[:id])
    items = category.items.priority.select(:id, :name, :price, :cover, :position, :special_price).where("status = ?", "0").uniq.page(params[:page]).per_page(20)

    render json: items
  end
end