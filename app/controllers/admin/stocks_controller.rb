class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @stocks = @taobao_supplier.stocks.includes(:stock_specs).recent
  end
end