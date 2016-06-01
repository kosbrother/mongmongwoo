class Staff::ItemsController < StaffController
  before_action :require_assistant
  before_action :find_item, only: [:show, :edit, :update, :destroy]

  def index
    @item_page = @items = Item.priority.paginate(:page => params[:page])

    respond_to do |format|
      format.html
    end
  end

  def new
    @item = Item.new
    @photo = @item.photos.new
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      flash[:notice] = "新增商品成功"
      redirect_to staff_item_path(@item)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @item.update(item_params)
      flash[:notice] = "成功更新商品"
      redirect_to staff_item_path(@item)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :edit
    end
  end

  def destroy
    @item.destroy
    flash[:warning] = "商品已刪除"
    redirect_to staff_root_path
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :special_price, :cover, :slug, :description, :url, :taobao_supplier_id, :cost, category_ids: [])
  end

  def find_item
    @item = Item.find(params[:id])
    @photos = @item.photos
    @specs = @item.specs
  end
end