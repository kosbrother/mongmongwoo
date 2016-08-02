class Admin::ItemsController < AdminController
  before_action :require_manager
  before_action :find_item, only: [:show, :edit, :update, :destroy, :on_shelf, :off_shelf, :specs]

  def new
    @item = Item.new
    @photo = @item.photos.new
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      flash[:notice] = "新增商品成功"
      redirect_to admin_item_path(@item)
    else
      flash.now[:alert] = "請確認欄位資料"
      render :new
    end
  end

  def show
    @sales_volume = @item.sales_quantity
    @sales_volume_monthly = @item.sales_quantity_within_date(TimeSupport.time_until("month"))
    @sales_volume_weekly = @item.sales_quantity_within_date(TimeSupport.time_until("week"))
  end

  def update
    if @item.update(item_params)
      flash[:notice] = "成功更新商品"
      redirect_to admin_item_path(@item)
    else
      flash.now[:alert] = "請確認欄位名稱"
      render :edit
    end
  end

  def destroy
    @item.destroy
    flash[:warning] = "商品已刪除"
    redirect_to admin_root_path
  end

  def on_shelf
    @item.update_column(:status, 0)
  end

  def off_shelf
    @item.update_column(:status, 1)
  end

  def search
    @search_results_page = @search_results = Item.search_by_name(params[:search_term]).paginate(:page => params[:page])
  end

  def specs
    render json: @specs
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :special_price, :cover, :slug, :description, :url, :taobao_supplier_id, :cost, :shelf_position, :real_name, category_ids: [])
  end

  def find_item
    @item = Item.find(params[:id])
    @photos = @item.photos
    @specs = @item.specs.order(status: :ASC).includes(:stock_spec)
  end
end