class Admin::AdminCartItemsController < AdminController
  before_action :find_cart_item, only: [:update_spec, :update_quantity,:destroy]
  before_action :create_cart_item, only: [:create, :add]

  def create
    redirect_to :back
  end


  def add
    @result = '已新增至購物車'
    render 'notify'
  end

  def get_by_id
    @item = Item.select(:id, :status, :name, :taobao_supplier_id).find_by_id(params[:item_id])
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

  def destroy
    @cart_item.destroy
  end

  private

  def create_cart_item
    supplier_cart_items = current_supplier_cart(params[:taobao_supplier_id]).admin_cart_items
    @cart_item = supplier_cart_items.find_or_create_by(item_id: params[:item_id], item_spec_id: params[:item_spec_id])
    if @cart_item.item_quantity
      @cart_item.item_quantity += params[:item_quantity].to_i
    else
      @cart_item.item_quantity = params[:item_quantity].to_i
    end
    @cart_item.save
  end

  def find_cart_item
    @cart_item = AdminCartItem.find(params[:id])
  end
end