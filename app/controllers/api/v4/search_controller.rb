class  Api::V4::SearchController < ApiController
  def search_items
    items =  Item.select(:id, :name, :price, :special_price, :cover, :slug).search_name_and_description(params[:query]).page(params[:page]).per_page(20).records

    datas = items.as_json(methods: [:discount_icon_url], include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
    datas.each{|data| data["specs"] = data.delete "on_shelf_specs"}

    render status: 200, json:  {data: datas}
  end
end
