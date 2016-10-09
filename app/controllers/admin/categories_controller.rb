class Admin::CategoriesController < AdminController
  include Admin::CategoriesHelper
  before_action only: [:new, :create, :import_excel] do
    accept_role(:manager)
  end
  before_action except: [:new, :create, :import_excel] do
    accept_role(:manager, :staff)
  end
  before_action :find_category, only: [:show, :edit, :update, :destroy, :subcategory]

  def index
    @categories = Category.parent_categories.paginate(:page => params[:page])
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:notice] = "新增分類成功"
      redirect_to parent_category_path(@category)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :new
    end
  end

  def show
    @parent_category = @category.parent_category
    @child_categories = @category.child_categories.paginate(:page => params[:page])
  end

  def update
    if @category.update(category_params)
      flash[:notice] = "分類已更新完成"
      redirect_to parent_category_path(@category)
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

  def subcategory
    categories = @category.child_categories

    render status: 200, json: {data: categories}
  end

  def import_excel
    xlsx = Roo::Spreadsheet.open(params['excel_file'], extension: :xlsx)
    sheet = xlsx.sheet(0)
    records = sheet.parse(item_id: '商品編號', class_1: '商品類別1', class_2: '商品類別2', class_3: '商品類別3', sub_class_1: '子分類1', sub_class_2: '子分類2', sub_class_3: '子分類3')
    records.each_with_index do |hash, index|
      next if index < 1
      set_item_category(hash)
    end
    flash[:notice] = "商品分類已匯入完成"
    redirect_to :back
  end

  private

  def set_item_category(hash)
    item = Item.find(hash[:item_id])
    hash.delete(:item_id)
    item.categories.delete_all
    categories =[]
    hash.each do |key,value|
      next if value.blank?
      raise NotFindCategoryError unless Category.exists?(name: value)
      if key.to_s.include?("sub")
        key = key.to_s.gsub("sub_","")
        category = Category.find_by(name: hash[key.to_sym])
        new_categories = Category.where(name: value,parent_id: category.id)
      else
        new_categories = Category.where("name = ?",value)
      end
      categories += new_categories
    end
    item.categories << categories.uniq{|x| x.id}
  end

  def category_params
    params.require(:category).permit(:name, :image, :parent_id)
  end

  def find_category
    @category = Category.find(params[:id])
  end
end