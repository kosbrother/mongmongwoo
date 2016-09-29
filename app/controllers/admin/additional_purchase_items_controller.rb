class Admin::AdditionalPurchaseItemsController < AdminController
  before_action { accept_role(:manager) }
  before_action :find_additional_purchase_item, only: [:edit, :update, :destroy]

  def index
    @additional_purchase_items = AdditionalPurchaseItem.includes(:item).recent.paginate(page: params[:page])
  end

  def new
    @additional_purchase_item = AdditionalPurchaseItem.new
  end

  def create
    @additional_purchase_item = AdditionalPurchaseItem.new(additional_purchase_item_params)

    if @additional_purchase_item.save
      flash[:notice] = "成功新增加購優惠"
      redirect_to admin_additional_purchase_items_path
    else
      flash.now[:alert] = "請確認輸入資料是否正確"
      render :new
    end
  end

  def update
    if @additional_purchase_item.update(additional_purchase_item_params)
      flash[:notice] = "成功更新加購優惠"
      redirect_to admin_additional_purchase_items_path
    else
      flash.now[:alert] = "請確認輸入資料是否正確"
      render :edit
    end
  end

  def destroy
    @additional_purchase_item.destroy
    flash[:warning] = "已刪除加購優惠"
    redirect_to admin_additional_purchase_items_path
  end

  private

  def additional_purchase_item_params
    params.require(:additional_purchase_item).permit(:price, :item_id)
  end

  def find_additional_purchase_item
    @additional_purchase_item = AdditionalPurchaseItem.find(params[:id])
  end
end