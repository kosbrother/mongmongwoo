class Api::V4::ItemsController < ApiController
  def index
    category = Category.find(params[:category_id])
    sort = params.fetch(:sort, "popular")
    items = category.items.on_shelf.order(Item.sort_params[sort]).includes(:on_shelf_specs).select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(30)
    datas = items.as_json(methods: [:discount_icon_url], include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] }})
    datas.each{|data| data["specs"] = data.delete "on_shelf_specs"}

    render status: 200, json: {data: datas}
  end

  def show
    category = Category.find(params[:category_id])
    item = category.items.select(:id, :name, :price, :special_price, :cover, :description, :status, :slug).find(params[:id])
    item_json = item.as_json(methods: [:discount_icon_url, :sales_quantity])
    campaign_rule = item.campaign_rule
    item_json[:campaign_url] = campaign_rule.present? ? campaign_rule.app_index_url : nil

    specs = item.specs.on_shelf.select(:id,:style,:style_pic).with_stock_amount.as_json
    photos = item.photos.select(:id, :image).as_json(only: [:image])
    item_json[:specs] = specs
    item_json[:photos] = photos

    render status: 200, json: {data: item_json}
  end
end