class Api::V3::RoadsController < ApiController
  def index
    county = County.find(params[:county_id])
    town = county.towns.find(params[:town_id])
    roads = town.roads.id_and_name

    render json: roads
  end
end