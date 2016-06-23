class Api::V3::ShopInfosController < ApiController
  def index
    shop_infos = ShopInfo.all

    render status: 200, json: {data: shop_infos}
  end
end