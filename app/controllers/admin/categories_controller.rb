class Admin::CategoriesController < AdminController
  layout "admin"
  before_action :require_manager

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
    @category = Category.find(params[:id])
    params['order'] = 'position' if params['order'].nil?
    if params['order'] == 'update'
      @on_shelf_items = @category.items.on_shelf.update_time
      @off_shelf_items = @category.items.off_shelf.update_time
    elsif params['order'] == 'position'
      @on_shelf_items = @category.items.on_shelf.priority
      @off_shelf_items = @category.items.off_shelf.priority
    end
  end

  def sort_items_priority
    params[:item].each_with_index do |id, index|
      ItemCategory.where(category_id: params[:category],item_id: id).update_all({position: index + 1})
    end

    render nothing: true
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

end