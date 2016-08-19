class Staff::CategoriesController < StaffController
  before_action :require_assistant
  before_action :find_category, only: [:show, :subcategory]

  def index
    @categories = Category.parent_categories
  end

  def show
    @category_items = @category.items.update_time.paginate(:page => params[:page])
  end

  def subcategory
    categories = @category.child_categories

    render status: 200, json: {data: categories}
  end

  private

  def find_category
    @category = Category.find(params[:id])
  end
end