class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.all
    params[:taobao_supplier_id] ||= @taobao_suppliers.first.id
    query_hash = params.permit(:taobao_supplier_id ,:status)
    @items = Item.includes(:specs).where(query_hash).recent.paginate(page: params[:page])
  end

  def edit
    @stock = Item.includes(specs: :stock_spec).find(params[:id])
  end
end