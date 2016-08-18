class Staff::CategoriesController < StaffController
  before_action :require_assistant
  before_action :find_category, only: [:show]

  def index
    @categories = Category.parent_categories
  end

  def show
    @category_items = @category.items.update_time.paginate(:page => params[:page])
  end

  private

  def find_category
    @category = Category.includes(:items).find(params[:id])
  end
end