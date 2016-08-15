class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.all
    params[:taobao_supplier_id] ||= @taobao_suppliers.first.id
    taobao_supplier = @taobao_suppliers.find(params[:taobao_supplier_id])
    items = taobao_supplier.items.includes(:specs)
    status_hash = params.permit(:status)
    @items = items.where(status_hash).recent.paginate(page: params[:page])
  end

  def edit
    @stock = Item.includes(specs: :stock_spec).find(params[:id])
  end
end