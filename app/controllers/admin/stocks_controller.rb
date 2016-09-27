class Admin::StocksController < AdminController
  before_action do
    accept_role(:manager)
  end

  def index
    query_hash = {}
    query_hash = query_hash.merge(status: params[:status], ever_on_shelf: true) if params[:status]
    query_hash = query_hash.merge(ever_on_shelf: false) if params[:ever_on_shelf] == 'false'
    @items = Item.includes(:specs).where(query_hash).recent.paginate(page: params[:page])
  end

  def edit
    @item = Item.includes(specs: :stock_spec).find(params[:id])
  end
end