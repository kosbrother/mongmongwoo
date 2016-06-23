class Admin::ShopInfosController < AdminController
  before_action :require_manager

  def index
    @infos = ShopInfo.all
  end

  def new
    @info = ShopInfo.new
  end

  def create
   @info = ShopInfo.new(info_params)
   if @info.save
     flash[:notice] = "成功新增購物須知"
     redirect_to admin_shop_infos_path
   else
     flash[:danger] = "請檢查資料是否正確"
     render :new
   end
  end

  def destroy
    @info = ShopInfo.find(params[:id])
    @info.destroy
    flash[:notice] = "成功刪除購物須知"
    redirect_to admin_shop_infos_path
  end

  private

  def info_params
    params.require(:shop_info).permit(:question, :answer)
  end
end
