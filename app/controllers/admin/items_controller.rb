class Admin::ItemsController < AdminController
  before_action :require_manager
  before_action :find_item, only: [:show, :edit, :update, :destroy, :on_shelf, :off_shelf, :specs]

  def index
    @categories = Category.parent_categories
    params[:category_id] ||= Category::ALL_ID
    params[:order] ||= 'position'
    query_hash = {item_categories: {category_id: params[:category_id]}}
    query_hash = query_hash.merge({status: params[:status]}) if params[:status]

    if params[:order] == 'updated_at'
      order_query = {updated_at: :DESC}
    elsif params[:order] == 'position'
      order_query = "item_categories.position ASC"
    end

    @items = Item.joins(:item_categories).select('items.*, item_categories.position').where(query_hash).order(order_query).paginate(page: params[:page])
  end

  def new
    @item = Item.new
    @photo = @item.photos.new
  end

  def create
    @item = Item.new(item_with_tag_params)

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
    if @item.update(item_with_tag_params)
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
    redirect_to :back
  end

  def on_shelf
    if @item.ever_on_shelf == false
      @item.update_attributes(status: Item.statuses["on_shelf"], ever_on_shelf: true, created_at: Time.current)
    else
      @item.update_attribute(:status, Item.statuses["on_shelf"])
    end
  end

  def off_shelf
    @item.update_attribute(:status, Item.statuses["off_shelf"])
  end

  def search
    @search_results = Item.search_by_name_or_id(params[:search_term]).paginate(:page => params[:page])
  end

  def specs
    render json: @specs
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :special_price, :cover, :slug, :description, :url, :taobao_supplier_id, :cost, :shelf_position, :taobao_name, :note, category_ids: [])
  end

  def item_with_tag_params
    tag_list = params[:item][:tag_list].join(", ")
    item_params.merge!(tag_list: tag_list)
  end

  def find_item
    @item = Item.find(params[:id])
    @photos = @item.photos
    @specs = @item.specs.order(status: :ASC)
  end
end