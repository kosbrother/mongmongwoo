class Admin::CategoriesController < AdminController
  layout "admin"
  before_action :require_manager
  before_action :find_category, only: [:show]

  def index
    @categories = Category.recent
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:notice] = "新增分類成功"
      redirect_to admin_categories_path
    else
      flash.now[:alert] = "請確認欄位資料"
      render :new
    end
  end

  def show
    if params['order'] == 'update'
      @category_items = @category.items.update_time
    else
      @category_items = @category.items.priority
    end
  end

  def sort_items_priority
    params[:item].each_with_index do |id, index|
      Item.where(id: id).update_all({position: index + 1})
    end

    render nothing: true
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def find_category
    @category = Category.includes(:items).find(params[:id])
  end
end