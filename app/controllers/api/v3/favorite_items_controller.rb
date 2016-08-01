class Api::V3::FavoriteItemsController < ApiController
  before_action :find_user

  def index
    favorite_items = @user.favorite_items.as_json({only: [:id], include: {item:{only: [:id, :name, :cover, :price], methods: [:final_price]}}})

    render status: 200, json: {data: favorite_items}
  end

  def create
    favorite_items_params.each do |params|
      favorite_item = @user.favorite_items.find_or_create_by(params)
      favorite_item.save if favorite_item.new_record?
    end

    render status: 200, json: {data: "success"}
  end

  def destroy
    favorite_item = @user.favorite_items.find_by(item_id: params[:item_id])
    favorite_item.destroy

    render status: 200, json: {data: "success"}
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def favorite_items_params
    params.permit(:favorite_items => [:item_id])[:favorite_items]
  end
end