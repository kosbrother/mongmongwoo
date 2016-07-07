class  Api::V3::SearchController < ApiController
  def search_items
    items =  Item.search_name_and_description(params[:query]).records.on_shelf.select(:id, :name, :price, :special_price, :cover, :slug).page(params[:page]).per_page(20)

    datas = items.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic] } })
    datas.each{|data| data["specs"] = data["on_shelf_specs"]}

    render status: 200, json:  {data: datas}
  end
end
