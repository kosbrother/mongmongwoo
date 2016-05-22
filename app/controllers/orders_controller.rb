class OrdersController < ApplicationController
  layout 'user'

  before_action  :load_categories

  def index
    @orders = current_user.orders
  end

  def show
  end
end
