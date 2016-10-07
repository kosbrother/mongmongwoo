class Admin::ItemsController < AdminController
  before_action only: [:on_shelf, :off_shelf] do
    accept_role(:manager)
  end
  before_action except: [:on_shelf, :off_shelf] do
    accept_role(:manager, :staff)
  end
  before_action :find_item, only: [:show, :edit, :update, :destroy, :on_shelf, :off_shelf, :specs, :update_initial_on_shelf_date]

  def index
    params[:category_id] ||= Category::ALL_ID
    params[:order] ||= 'position'
    query_hash = {item_categories: {category_id: params[:category_id]}}
    query_hash = query_hash.merge(status: params[:status], ever_on_shelf: true) if params[:status]
    query_hash =  query_hash.merge(ever_on_shelf: false) if params[:ever_on_shelf] == 'false'

    case(params[:order])
    when 'updated_at'
      order_query = {updated_at: :DESC}
    when 'position'
      order_query = "item_categories.position ASC"
    when 'id'
      order_query = {id: :DESC}
    end
    @categories = Category.parent_categories
    if @categories.map(&:id).include? params[:category_id].to_i
      @subcategories = Category.find(params[:category_id]).child_categories
    else
      @subcategories = Category.subcategories(Category.find(params[:category_id]).parent_id)
    end
    @tags =  ActsAsTaggableOn::Tag.all
    items = params[:tag] ? Item.tagged_with(params[:tag]) : Item
    @items = items.joins(:item_categories).select('items.*, item_categories.position').where(query_hash).order(order_query).paginate(page: params[:page])
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
    @categories = @item.categories.includes(:parent_category)
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
      @item.remove_existed_new_on_shelf_categories
    end
    @item.reload.set_new_on_shelf_categories
  end

  def off_shelf
    @item.update_attribute(:status, Item.statuses["off_shelf"])
    @item.remove_existed_new_on_shelf_categories
  end

  def search
    @search_results = Item.search_by_name_or_id(params[:search_term]).paginate(:page => params[:page])
  end

  def specs
    render json: @specs
  end

  def update_initial_on_shelf_date
    @item.update_attribute(:created_at, params[:datetime])
    @item.remove_existed_new_on_shelf_categories
    @item.reload.set_new_on_shelf_categories
    flash[:notice] = "已更新首次上架日期"
    redirect_to admin_item_path(@item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :special_price, :cover, :slug, :description, :url, :taobao_supplier_id, :cost, :shelf_position, :taobao_name, :note, category_ids: [])
  end

  def item_with_tag_params
    tag_list = params[:item][:tag_list].join(", ")
    item_params.merge(tag_list: tag_list)
  end

  def find_item
    @item = Item.find(params[:id])
    @photos = @item.photos
    @specs = @item.specs.order(status: :ASC)
  end
end