class Admin::StoresController < AdminController
  before_action except: [:get_store_options] do
    accept_role(:manager)
  end
  before_action :find_store, only: [:edit, :update, :destroy]

  def index
    @stores = Store.seven_stores.by_store_code_or_name(params[:store_code], params[:store_name])
  end

  def new
    @store = Store.new(county_id: County::TAIPEI_CITY_ID)
  end

  def create
    @store = Store.new(store_params)
    town = Town.find(params[:store][:town_id])
    road = town.roads.find_or_create_by(name: params[:road_name])
    @store.road = road
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