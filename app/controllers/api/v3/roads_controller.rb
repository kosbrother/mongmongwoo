class Api::V3::RoadsController < ApiController
  def index
    county = County.find(params[:county_id])
    town = county.towns.find(params[:town_id])
    roads = town.roads.select_api_fields

    render status: 200, json: {data: roads}
  end
end