class Api::V3::TownsController < ApiController
  def index
    county = County.find(params[:county_id])
    @towns = county.towns.includes(:roads, :stores)

    render json: @towns, only: [:id, :name]
  end
end