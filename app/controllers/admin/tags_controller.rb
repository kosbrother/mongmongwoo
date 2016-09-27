class Admin::TagsController < AdminController
  before_action do
    accept_role(:manager, :staff)
  end
  before_action :find_tag, only: [:show, :edit, :update, :destroy]

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

  def show
    @items = Item.tagged_with(@tag.name).paginate(:page => params[:page])
  end

  def update
    if @tag.update(tag_params)
      flash[:notice] = "成功更新標籤"
      redirect_to admin_tag_path(@tag)
    else
      flash.now[:alert] = "請輸入標籤名稱"
      render :edit
    end
  end

  def destroy
    @tag.destroy
    flash[:warning] = "已刪除標籤"
    redirect_to admin_tags_path
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :taggings_count)
  end

  def find_tag
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
  end
end