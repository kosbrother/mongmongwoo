class Api::V4::ShoppingPointsController < ApiController
  before_action :find_user

  def index
    shopping_points = @user.shopping_points
    total = shopping_points.valid.sum(:amount)
    record_format = {shopping_point_records: {only: [:created_at, :order_id, :amount, :balance]}}
    shopping_points_json = shopping_points.as_json({only: [:point_type, :amount, :valid_until], methods: :description, include: record_format})

    render status: 200, json: {data: {total: total, shopping_points: shopping_points_json}}
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end
end