class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.all
    params[:taobao_supplier_id] ||= TaobaoSupplier::DEFAULT_ID.to_s
    taobao_supplier = @taobao_suppliers.find(params[:taobao_supplier_id])
    items = taobao_supplier.items.includes(specs: :stock_spec)
    items = items.where(status: params[:status]) if params[:status]
    @items = items.recent.paginate(page: params[:page])
  end
end