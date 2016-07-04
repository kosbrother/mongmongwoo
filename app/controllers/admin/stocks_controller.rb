class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
    @item_ids_in_stock_without_supplier = Stock.by_taobao_supplier(nil).map(&:item_id).join("，")
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @stocks = Stock.by_taobao_supplier(@taobao_supplier.id)
  end

  def anoymous_supplier_stocks
    @anoymous_supplier_stocks = Stock.by_taobao_supplier(nil)
  end
end