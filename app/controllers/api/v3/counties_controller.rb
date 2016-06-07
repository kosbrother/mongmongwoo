class Api::V3::CountiesController < ApiController
  def index
    counties = County.seven_stores.select_api_fields

    render status: 200, json: {data: counties}
  end
end