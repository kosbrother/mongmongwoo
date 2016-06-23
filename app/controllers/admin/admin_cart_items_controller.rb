class Admin::AdminCartItemsController < AdminController
  before_action :find_cart_item, only: [:update_spec, :destroy]
  before_action :create_cart_item, only: [:create, :add]

  def create
    redirect_to :back
  end


  def add
    @result = '以新增至購物車'
    render 'notify'
  end

  def find_by_id
    @item = Item.joins('LEFT JOIN taobao_suppliers ON taobao_suppliers.id = items.taobao_supplier_id').select('taobao_suppliers.name as supplier', :id, :status, :name, :taobao_supplier_id).find_by_id(params[:item_id])
    if @item
      @item.supplier = '無' unless @item.supplier
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
    cart_item = AdminCartItem.find(params[:id])
    cart_item.item_quantity = params[:item_quantity]
    @result = '數量已更新'
    render status: 400 unless cart_item.save
    render 'notify'
  end

  def destroy
    @cart_item.destroy
  end

  private

  def create_cart_item
    @cart_item = AdminCartItem.create(cart_item_params)
  end

  def find_cart_item
    @cart_item = current_supplier_cart(params['taobao_supplier_id']).admin_cart_items.find(params[:id])
  end

  def cart_item_params
    params.permit(:item_id, :item_spec_id, :item_quantity).merge({ admin_cart_id: current_supplier_cart( params['taobao_supplier_id']).id})
  end
end