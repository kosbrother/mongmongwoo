class Api::V3::WishListsController < ApiController
  before_action :find_user

  def index
    wish_lists = @user.wish_lists.as_json({only: [:id], include: {item:{only: [:id, :name, :price], methods: [:final_price]}, item_spec: {only: [:id, :style, :style_pic], methods: [:stock_amount]}}})

    render status: 200, json: {data: wish_lists}
  end

  def create
    wish_lists_params.each do |params|
      wish_list = @user.wish_lists.find_or_create_by(params)
      wish_list.save if wish_list.new_record?
    end

    render status: 200, json: {data: "success"}
  end

  def destroy
    wish_list = @user.wish_lists.find_by(item_spec_id: params[:item_spec_id])
    wish_list.destroy

    render status: 200, json: {data: "success"}
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def wish_lists_params
    params.permit(:wish_lists => [:item_id, :item_spec_id])[:wish_lists]
  end
end