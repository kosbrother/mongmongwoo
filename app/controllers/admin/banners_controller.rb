class Admin::BannersController < AdminController
  before_action do
    accept_role(:manager)
  end

  def index
    @banners = Banner.includes(:bannerable).recent.paginate(page: params[:page])
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)

    if @banner.save
      flash[:notice] = "成功新增廣告"
      redirect_to admin_banners_path
    else
      flash[:alert] = "請確認資料是否正確"
      render :new
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    flash[:warning] = "已刪除廣告"
    redirect_to admin_banners_path
  end

  def render_select_form
    @banner_type = params[:banner_type]
  end

  private

  def banner_params
    params.require(:banner).permit(:bannerable_id, :bannerable_type, :title, :image, :record_type)
  end
end