class Api::V3::ShopInfosController < ApiController
  def index
    shop_infos = ShopInfo.all.as_json({except: [:id, :created_at, :updated_at]})
    render status: 200, json: shop_infos
  end
end