class Admin::TaobaoSuppliersController < AdminController
  before_action do
    accept_role(:manager)
  end
  before_action :find_taobao_supplier, only: [:edit, :update, :destroy, :items, :show]

  def index
    @taobao_suppliers = TaobaoSupplier.includes(:items).paginate(page: params[:page])
    items_count = Item.group(:status).count
    @on_shelf_items_count = items_count[Item.statuses[:on_shelf]]
    @off_shelf_items_count = items_count[Item.statuses[:off_shelf]]
  end

  def new
    @taobao_supplier = TaobaoSupplier.new
  end

  def create
    @taobao_supplier = TaobaoSupplier.new(taobao_supplier_params)

    if @taobao_supplier.save
      flash[:notice] = "成功新增淘寶商家"
      redirect_to admin_taobao_suppliers_path
    else
      flash[:danger] = "請檢察輸入的資料是否正確"
      render :new
    end
  end

  def update
    if @taobao_supplier.update(taobao_supplier_params)
      flash[:notice] = "淘寶商家資料更新完成"
      redirect_to admin_taobao_suppliers_path
    else
      flash[:danger] = "請檢察輸入的資料是否正確"
      render :edit
    end
  end

  def destroy
    @taobao_supplier.destroy
    flash[:warning] = "已刪除淘寶商家資料"
    redirect_to admin_taobao_suppliers_path
  end

  def items
    item_list =  @taobao_supplier.items
    first_item_specs = @taobao_supplier.items.first.specs
    render json: {items: item_list, specs: first_item_specs}
  end

  def show
    @items = @taobao_supplier.items.includes(:specs).where(status: params[:status]).paginate(page: params[:page], per_page: 100)
  end

  private

  def taobao_supplier_params
    params.require(:taobao_supplier).permit(:name, :url)
  end

  def find_taobao_supplier
    @taobao_supplier = TaobaoSupplier.find(params[:id])
  end
end