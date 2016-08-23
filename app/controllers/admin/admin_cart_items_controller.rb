class Admin::AdminCartItemsController < AdminController
  before_action :require_manager
  before_action :find_cart_item, only: [:update_spec, :update_quantity,:destroy, :update_actual_quantity]
  before_action :create_cart_item, only: [:create, :add]

  def create
    flash[:notice] = "#{@cart_item.item.name}已新增至購物車"
    redirect_to checkout_admin_admin_carts_path(item_id: params[:item_id])
  end

  def add
    @result = '已新增至購物車'
    render 'notify'
  end

  def get_by_id
    @item = Item.includes(:specs).find_by_id(params[:item_id])
    if @item
      @item.taobao_supplier ? @supplier_name = @item.taobao_supplier.name : @supplier_name = '無'
      @specs = @item.specs.select(:id, :style, :style_pic)
    else
      render js: "alert('找不到該商品');"
    end
  end

  def update_spec
    @cart_item.item_spec_id = params[:spec_item_id]
    @cart_item.save
  end

  def update_quantity
    @cart_item.item_quantity = params[:item_quantity]
    @result = '數量已更新'
    @cart_item.save
    render 'notify'
  end

  def update_actual_quantity
    @cart_item.actual_item_quantity = params[:actual_item_quantity]
    @result = '實際到貨數量已更新'
    @cart_item.save
  end

  def destroy
    @cart = @cart_item.admin_cart
    @cart_item.destroy
    if @cart.admin_cart_items.blank?
      @cart.destroy
      session[:admin_cart_ids].delete(@cart.id)
    end
  end

  def import_excel
    xlsx = Roo::Spreadsheet.open(params['excel_file'], extension: :xlsx)
    records = xlsx.parse(taobao_supplier: '商家', item_id: '商品編號', item_spec_id: '商品樣式編號', item_quantity: '採購量')
    records.each_with_index do |hash, index|
      next if index == 0
      taobao_supplier_id = TaobaoSupplier.find_by(name: hash[:taobao_supplier]).id

      create_cart_item(taobao_supplier_id, hash[:item_id], hash[:item_spec_id], hash[:item_quantity])
    end

    redirect_to :back
  end

  private

  def create_cart_item(taobao_supplier_id=params[:taobao_supplier_id], item_id=params[:item_id], item_spec_id=params[:item_spec_id], item_quantity=params[:item_quantity])
    supplier_cart_items = current_supplier_cart(taobao_supplier_id).admin_cart_items
    @cart_item = supplier_cart_items.find_or_create_by(item_id: item_id, item_spec_id: item_spec_id)
    @cart_item.add_item_quantity(item_quantity)
  end

  def find_cart_item
    @cart_item = AdminCartItem.find(params[:id])
  end
end