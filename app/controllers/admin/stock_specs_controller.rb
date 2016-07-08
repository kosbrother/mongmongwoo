class Admin::StockSpecsController < AdminController
  before_action :require_manager

  def update
    @stock_spec = StockSpec.find(params[:id])
    @stock_spec.update(params.require(:stock_spec).permit(:amount))
  end
end