class Admin::StoresController < AdminController
  before_action :require_manager, except: [:get_store]
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
    if @store.save
      flash[:notice] = "成功新增門市"
      redirect_to admin_stores_path
    else
      flash.now[:danger] = "店號不能重複"
      render :new
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

  def get_store
    store = Store.seven_stores.select(:id, :store_code, :name).find_by(store_code: params[:store_code])
    render status: 200, json: {data: store}
  end

  private

  def find_store
    @store = Store.find(params[:id]) 
  end

  def store_params
    params.require(:store).permit(:store_code, :name, :address, :phone, :lat, :lng, :store_type, :road_id, :town_id, :county_id)
  end
end