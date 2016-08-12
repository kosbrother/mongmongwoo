class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
    params[:taobao_supplier_id] ||= @taobao_suppliers.last.id
    @taobao_supplier = @taobao_suppliers.find(params[:taobao_supplier_id])
    @items = @taobao_supplier.items.includes(stock_specs: :item_spec).paginate(page: params[:page])
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @items = @taobao_supplier.items
  end

end