class Api::V4::ItemsController < ApiController
  def index
    category = Category.find(params[:category_id])
    sort = params.fetch(:sort, "popular")
    items = category.items.on_shelf.order(Item.sort_params[sort]).includes(:on_shelf_specs).select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(30)
    datas = items.as_json(methods: [:discount_icon_url], include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] }})
    datas.each{|data| data["specs"] = data.delete "on_shelf_specs"}

    render status: 200, json: {data: datas}
  end
end