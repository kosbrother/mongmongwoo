class Admin::StoresController < AdminController
  before_action :require_manager
  before_action :find_store, only: [:edit, :update, :destroy]

  def search_store
    @search_stores = Store.seven_stores.search_by_store_code_or_name(params[:store_code], params[:store_name])
  end

  def edit
  end

  def update
    if @store.update(store_params)
      flash[:notice] = "門市店號已更新"
      redirect_to search_store_admin_stores_path
    else
      flash.now[:danger] = "請確認資料正確"
      render :edit
    end
  end

  def destroy
    @store.destroy
    flash[:warning] = "門市已下架"
    redirect_to search_store_admin_stores_path
  end

  private

  def find_store
    @store = Store.find(params[:id]) 
  end

  def store_params
    params.require(:store).permit(:store_code)
  end
end