class Admin::CategoriesController < AdminController
  include Admin::CategoriesHelper
  before_action :require_manager
  before_action :find_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.recent.paginate(:page => params[:page])
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:notice] = "新增分類成功"
      redirect_to parent_category_page(@category)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :new
    end
  end

  def show
    @parent_category = @category.parent_category
    @child_categories = @category.child_categories.recent.paginate(:page => params[:page])
  end

  def update
    if @category.update(category_params)
      flash[:notice] = "分類已更新完成"
      redirect_to parent_category_page(@category)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :edit
    end
  end

  def destroy
    @category.destroy
    flash[:warning] = "分類已刪除"
    redirect_to :back
  end

  private

  def category_params
    params.require(:category).permit(:name, :image, :parent_id)
  end

  def find_category
    @category = Category.all_categories.find(params[:id])
  end
end