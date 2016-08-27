class Admin::TagsController < AdminController
  before_action :require_manager

  def index
    @tags = ActsAsTaggableOn::Tag.all.paginate(:page => params[:page])
  end

  def new
    @tag = ActsAsTaggableOn::Tag.new
  end

  def create
    @tag = ActsAsTaggableOn::Tag.new(tag_params)

    if @tag.save
      flash[:notice] = "成功新增標籤"
      redirect_to admin_tags_path
    else
      flash.now[:alert] = "請輸入標籤名稱"
      render :new
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :taggings_count)
  end
end