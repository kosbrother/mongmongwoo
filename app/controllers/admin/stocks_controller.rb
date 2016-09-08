class Admin::StocksController < AdminController
  before_action :require_manager

  def index
    @taobao_suppliers = TaobaoSupplier.all
    params[:taobao_supplier_id] ||= @taobao_suppliers.first.id
    query_hash = {taobao_supplier_id: params[:taobao_supplier_id]}
    query_hash = query_hash.merge(status: params[:status], ever_on_shelf: true) if params[:status]
    query_hash = query_hash.merge(ever_on_shelf: false) if params[:ever_on_shelf] == 'false'
    @items = Item.includes(:specs).where(query_hash).recent.paginate(page: params[:page])
  end

  def edit
    @item = Item.includes(specs: :stock_spec).find(params[:id])
  end
end