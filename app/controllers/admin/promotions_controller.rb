class Admin::PromotionsController < AdminController
  before_action :require_manager

  def index
    @promotions = Promotion.recent.paginate(:page => params[:page]) 
  end

  def new
    @promotion = Promotion.new
  end

  def create
    @promotion = Promotion.new(promotion_params)

    if @promotion.save
      flash[:notice] = "成功新增優惠活動"
      redirect_to admin_promotions_path
    else
      flash[:danger] = "請檢查資料是否正確"
      render :new
    end
  end

  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy
    flash[:warning] = "優惠活動已刪除"
    redirect_to admin_promotions_path
  end

  private

  def promotion_params
    params.require(:promotion).permit(:title, :content, :discount, :image)
  end
end