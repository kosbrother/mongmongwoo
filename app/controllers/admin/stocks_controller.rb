class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
    @item_ids_in_stock_without_supplier = Stock.taobao_supplier_stocks(nil).map(&:id).join("，")
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @stocks = Stock.taobao_supplier_stocks(@taobao_supplier.id)
  end

  def anoymous_supplier_stocks
    @anoymous_supplier_stocks = Stock.taobao_supplier_stocks(nil)
  end
end