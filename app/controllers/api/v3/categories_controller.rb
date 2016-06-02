class Api::V3::CategoriesController < ApiController
  def index
    categories = Category.all

    render json: categories, only: [:id, :name]
  end

  def show
    category = Category.find(params[:id])
    items = category.items.priority.select(:id, :name, :price, :cover, :position).where("status = ?", "0").uniq.page(params[:page]).per_page(20)

    render json: items
  end
end