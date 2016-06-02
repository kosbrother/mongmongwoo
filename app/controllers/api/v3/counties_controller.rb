class Api::V3::CountiesController < ApiController
  def index
    @counties = County.seven_stores

    render json: @counties, only: [:id, :name]
  end
end