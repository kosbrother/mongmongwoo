class Api::V3::CountiesController < ApiController
  def index
    counties = County.seven_stores.id_and_name

    render json: counties
  end
end