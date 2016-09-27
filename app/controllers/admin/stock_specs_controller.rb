class Admin::StockSpecsController < AdminController
  before_action do
    accept_role(:manager)
  end

  def create
    @stock_spec = StockSpec.create(stock_spec_params)
    flash[:notice] = "已建立商品庫存資料"
    redirect_to :back
  end

  def update
    @stock_spec = StockSpec.find(params[:id])
    @stock_spec.update(stock_spec_params)
  end

  private

  def stock_spec_params
    params.require(:stock_spec).permit(:amount, :item_id, :item_spec_id)
  end
end