class  Api::V3::SearchController < ApiController
  def search_items
    items =  Item.select(:id, :name, :price, :special_price, :cover, :slug).search_name_and_description(params[:query]).page(params[:page]).per_page(20).records

    datas = items.as_json(include: { on_shelf_specs: { only: [:id, :style, :style_pic], methods: [:stock_amount] } })
    datas.each{|data| data["specs"] = data["on_shelf_specs"]}

    render status: 200, json:  {data: datas}
  end

  def item_names
    names = Item.on_shelf.select(:name)
    render status: 200, json: {data: names.collect(&:name)}
  end

  def hot_keywords
    keywords = ["雨鞋套","水杯水瓶","貼紙","韓版","便利貼","賀卡","筆袋","錢包","斜肩背包","髮圈","衛生棉包","收納袋","飾品","襪子","紋身貼"]
    render status: 200, json: {data: keywords}
  end
end
