class Api::V3::ItemsController < ApiController
  def index
    category = Category.find(params[:category_id])
    if(params[:sort].present?)
      items = category.items.on_shelf.order(Item.sort_params[params[:sort]]).includes(:on_shelf_specs).select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(30)
    else
      items = category.items.on_shelf.priority.includes(:on_shelf_specs).select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(30)
    end

    datas = items.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
    datas.each{|data| data["specs"] = data["on_shelf_specs"]}

    render status: 200, json: {data: datas}
  end

  def show
    category = Category.find(params[:category_id])
    item = category.items.select(:id, :name, :price, :special_price, :cover, :description, :status, :slug).find(params[:id])
    item_json = item.as_json
    specs = item.specs.on_shelf.select(:id,:style,:style_pic).with_stock_amount
    photos = item.photos.select(:id, :image)

    item_json[:specs] = specs
    item_json[:photos] = photos.as_json(only: [:image])

    render status: 200, json: {data: item_json}
  end
end