class ApiController < ActionController::Base
  def find_county
    @county = County.seven_cvs.find(params[:county_id])
  end

  def find_town
    @town = @county.towns.seven_cvs.find(params[:town_id]) 
  end

  def find_road
    @road = @town.roads.seven_cvs.find(params[:road_id])
  end

  def android_version
    render json: AndroidVersion.last
  end
end