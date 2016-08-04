class Api::V3::ShoppingPointsController < ApiController
  before_action :find_user

  def index
    points = @user.shopping_points
    render status: 200, json: {data: points}
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end
end