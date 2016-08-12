class Admin::StockSpecsController < AdminController
  before_action :require_manager
  before_action :find_stock_spec, only: [:edit, :update]

  def update
    @stock_spec = StockSpec.find(params[:id])
    if @stock_spec.update(stock_spec_params)
      flash[:notice] = "更新庫存成功"
      redirect_to admin_stocks_path(taobao_supplier_id: @stock_spec.taobao_supplier_id, anchor: "stock-id-#{@stock_spec.item_id}")
    else
      flash.now[:alert] = "請檢查資料是否正確"
      render :new
    end
  end

  private

  def stock_spec_params
    params.require(:stock_spec).permit(:amount)
  end

  def find_stock_spec
    @stock_spec = StockSpec.find(params[:id])
  end
end