class Api::V3::CountiesController < ApiController
  def index
    @counties = County.includes(:towns, :stores).seven_stores

    render json: @counties, only: [:id, :name]
  end

  def show
    @county = County.find(params[:id])
    @towns_in_county = @county.towns

    render json: @towns_in_county, only: [:id, :name]
  end
end