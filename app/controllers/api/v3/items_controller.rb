class Api::V3::ItemsController < ApiController
  def index
    category = Category.find(params[:category_id])
    items = category.items.on_shelf.priority.includes(:specs).select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(20)

    render status: 200, json: {data: items.as_json(include: { specs: { only: [:id, :style, :style_pic] } })}
  end

  def show
    category = Category.find(params[:category_id])
    item = category.items.select(:id, :name, :price, :special_price, :cover, :description, :status, :slug).find(params[:id])
    item_json = item.as_json
    specs = item.specs.on_shelf.select(:id,:style,:style_pic)
    photos = item.photos.select(:id, :image)

    item_json[:specs] = specs.as_json(only: [:id, :style, :style_pic])
    item_json[:photos] = photos.as_json(only: [:image])

    render status: 200, json: {data: item_json}
  end
end