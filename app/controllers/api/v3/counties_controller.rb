class Api::V3::CountiesController < ApiController
  def index
    counties = County.seven_stores.select(:id, :name)

    render json: counties
  end
end