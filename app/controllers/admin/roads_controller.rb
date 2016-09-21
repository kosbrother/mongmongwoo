class Admin::RoadsController < AdminController
  def get_road_options
    town = Town.find(params[:town_id])
    roads = town.roads.where("name LIKE :name", name: "%#{params[:road_name]}%").pluck(:name)
    render status: 200, json: {data: roads}
  end
end