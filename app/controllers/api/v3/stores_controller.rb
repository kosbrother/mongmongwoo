class Api::V3::StoresController < ApiController
  def index
    county = County.find(params[:county_id])
    town = county.towns.find(params[:town_id])
    road = town.roads.find(params[:road_id])
    stores = road.stores

    render json: stores, only: [:id, :store_code, :name, :address, :phone, :lat, :lng]
  end
end