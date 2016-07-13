class Admin::StoresController < AdminController
  before_action :require_manager, except: [:get_store_options]
  before_action :find_store, only: [:edit, :update, :destroy]

  def index
    @stores = Store.seven_stores.by_store_code_or_name(params[:store_code], params[:store_name])
  end

  def new
    @counties = County.seven_stores
    @towns = @counties.first.towns
    @roads = @towns.first.roads
    @store = Store.new
  end

  def create
    @store = Store.new(store_params)
    road = Road.find_or_create_by(town_id: params[:store][:town_id], name: params[:road_name], store_type: 4)
    @store.road = road
    if @store.save
      flash[:notice] = "成功新增門市"
      redirect_to admin_stores_path
    else
      flash[:danger] = "店號不能重複"
      redirect_to new_admin_store_path
    end
  end

  def update
    if @store.update(store_params)
      flash[:notice] = "門市店號已更新"
      redirect_to admin_stores_path
    else
      flash.now[:danger] = "店號不能重複或空白"
      render :edit
    end
  end

  def destroy
    @store.destroy
    flash[:warning] = "門市已下架"
    redirect_to admin_stores_path
  end

  def get_store_options
    options = Store.seven_stores.where("store_code LIKE :store_code", store_code: "%#{params[:store_code]}%").pluck(:store_code, :name).collect { |s| s.join("：") }
    if options.any?
      render status: 200, json: { data: options }
    else
      render status: 400, json: { error: { message: "找不到此門市店號" } }
    end
  end

  private

  def find_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:store_code, :name, :address, :phone, :store_type, :town_id, :county_id)
  end
end