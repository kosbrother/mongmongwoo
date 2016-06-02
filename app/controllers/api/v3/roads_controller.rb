class Api::V3::RoadsController < ApiController
  def index
    county = County.find(params[:county_id])
    town = county.towns.find(params[:town_id])
    roads = town.roads

    render json: roads, only: [:id, :name]
  end
end