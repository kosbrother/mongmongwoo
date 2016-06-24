class Api::V3::ShopInfosController < ApiController
  def index
    shop_infos = ShopInfo.select(:id, :question, :answer).all
    render status: 200, json: shop_infos
  end
end