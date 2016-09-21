class Admin::PhotosController < AdminController
  before_action do
    accept_role(:manager, :staff)
  end
  before_action :find_item
  before_action :find_photo, only: [:edit, :update, :destroy]

  def index
    @photos = @item.photos
  end

  def new
    @photo = @item.photos.new
  end

  def create
    begin
      create_photo_params[:images].each do |image|
        @item.photos.create!(image: image)
      end
      flash[:notice] = "圖片上傳完成"
      redirect_to admin_item_photos_path(@item)
    rescue Exception => e
      flash.now[:alert] = "請確認上傳圖片是否正確"
    end
  end

  def update
    if @photo.update(update_photo_params)
      flash[:notice] = "編輯完成"
      redirect_to admin_item_photos_path(@item)
    else
      flash[:alert] = "請確認編輯內容是否正確"
      render :edit
    end
  end

  def destroy
    @photo.destroy
    flash[:warning] = "圖片已刪除"
    redirect_to admin_item_photos_path(@item)
  end

  def photo_sort
    params[:photo].each_with_index do |id, index|
      Photo.find(id).update(position: (params[:photo].count - (index + 1)))
    end
    render nothing: true
  end

  private

  def find_item
    @item = Item.find(params[:item_id])
  end

  def find_photo
    @photo = @item.photos.find(params[:id])
  end

  def create_photo_params
    params.require(:photo).permit(:image, :photo_intro).merge!(images: params[:images])
  end

  def update_photo_params
    params.require(:photo).permit(:image, :photo_intro)
  end
end