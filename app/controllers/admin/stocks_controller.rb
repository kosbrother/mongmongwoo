class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.recent
    @taobao_supplier = @taobao_suppliers.find(params[:taobao_supplier_id])

    if params[:status]
      @items = @taobao_supplier.items.includes(specs: :stock_spec).where(status: params[:status]).paginate(page: params[:page])
    else
      @items = @taobao_supplier.items.includes(specs: :stock_spec).paginate(page: params[:page])
    end
  end

  def stock_lists
    @taobao_supplier = TaobaoSupplier.find(params[:taobao_supplier_id])
    @items = @taobao_supplier.items
  end
end