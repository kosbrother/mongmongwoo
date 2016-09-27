class Admin::ItemSpecsController < AdminController
  before_action only: [:on_shelf, :off_shelf] do
    accept_role(:manager)
  end
  before_action except: [:on_shelf, :off_shelf] do
    accept_role(:manager, :staff)
  end
  before_action :find_item
  before_action :find_spec, only: [:edit, :update, :destroy, :on_shelf, :off_shelf, :style_pic, :stop_recommend, :start_recommend]

  def style_pic
    url = @item_spec.style_pic.url
    render json: {style_pic: url}
  end

  def new
    @item_spec = @item.specs.new
  end

  def create
    @item_spec = @item.specs.new(spec_params)

    if @item_spec.save
      flash[:notice] = "商品樣式新增完成"
      redirect_to admin_item_path(@item)
    else
      flash.now[:alert] = "請檢查資料是否正確"
      render :new
    end
  end

  def update
    if @item_spec.update(spec_params)
      flash[:notice] = "商品樣式更新完成"
      redirect_to admin_item_path(@item)
    else
      flash.now[:alert] = "請檢查資料是否正確"
      render :edit
    end
  end

  def on_shelf
    @item_spec.update_attribute(:status, ItemSpec.statuses["on_shelf"])
    @is_item_off_shelf = (@item_spec.item.status == "off_shelf")
  end

  def off_shelf
    @item_spec.update_attribute(:status, ItemSpec.statuses["off_shelf"])
    @set_item_off_shelf = (@item_spec.item.specs.on_shelf.size == 0 )
  end

  def stop_recommend
    @item_spec.update(is_stop_recommend: true)
    @message = '已將此產品設為停止建議補貨'
    render 'toggle_recommend'
  end

  def start_recommend
    @item_spec.update(is_stop_recommend: false)
    @message = '已將此產品重新設為建議補貨'
    render 'toggle_recommend'
  end

  private

  def find_item
    @item = Item.find(params[:item_id])
  end

  def find_spec
    @item_spec = @item.specs.find(params[:id])
  end

  def spec_params
    params.require(:item_spec).permit(:style, :style_pic, :shelf_position)
  end
end