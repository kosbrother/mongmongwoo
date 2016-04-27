class Api::V1::RoadsController < ApiController
  before_action :find_county, only: [:index]
  before_action :find_town, only: [:index]

  def index
    @roads = @town.roads.includes(:stores).seven_cvs

    render json: @roads, only: [:id, :name]
  end
end