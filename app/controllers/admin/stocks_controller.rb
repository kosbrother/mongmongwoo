class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @stocks = Stock.includes(:item, :stock_specs, stock_specs: [:item_spec]).where(items: { taobao_supplier_id: @taobao_supplier.id })
  end
end