class Admin::RoadsController < AdminController
  before_action :require_manager, except: [:get_road_options]

  def get_road_options
    town = Town.find(params[:town_id])
    roads = town.roads.where("name LIKE :name", name: "%#{params[:road_name]}%").pluck(:name)
    render status: 200, json: {data: roads}
  end
end