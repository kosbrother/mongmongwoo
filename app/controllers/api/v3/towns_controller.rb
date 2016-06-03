class Api::V3::TownsController < ApiController
  def index
    county = County.find(params[:county_id])
    towns = county.towns.select_api_fields

    render json: towns
  end
end