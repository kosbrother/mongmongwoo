class ShoppingPointsController < ApplicationController
  layout 'user'

  before_action  :load_categories_and_campaigns

  def index
    user = current_user || User.find(User::ANONYMOUS)
    @shopping_points = user.shopping_points.includes(:shopping_point_campaign, :shopping_point_records)
    @total = ShoppingPointManager.new(user).total_amount
  end
end