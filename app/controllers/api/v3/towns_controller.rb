class Api::V3::TownsController < ApiController
  def index
    county = County.find(params[:county_id])
    towns = county.towns.id_and_name

    render json: towns
  end
end