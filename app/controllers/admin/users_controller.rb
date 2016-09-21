class Admin::UsersController < AdminController
  before_action do
    accept_role(:manager)
  end
  skip_before_action :verify_authenticity_token, only: [:import_user]

  def index
    @users = User.recent.paginate(page: params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    @user = User.includes(orders: :info).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def import_user
    begin
      user = User.new
      user.user_name = params[:user_name]
      user.real_name = params[:real_name]
      user.gender = params[:gender]
      user.phone = params[:phone]
      user.address = params[:address]
      user.uid = params[:uid]
      user.save!
      render json: "Successfully Create"
    rescue Exception => e
      render json: "Error"
    end    
  end

  def show_uid
    @user = User.find_by(uid: params[:uid])

    respond_to do |format|
      format.json { render json: @user }
    end
  end

  def update
    user = User.find_by(uid: params[:id])
    begin
      user.user_name = params[:user_name]
      user.real_name = params[:real_name]
      user.gender = params[:gender]
      user.phone = params[:phone]
      user.address = params[:address]
      user.save!
      render json: "Successfully Update"
    rescue Exception => e
      render json: "Error"
    end
  end

  def search
    @search_term = search_params
    @users = User.search_by_search_terms(@search_term).paginate(page: params[:page])
  end

  def export_user_list
    @user_list = User.joins('LEFT JOIN orders ON orders.user_id = users.id').select('users.id, users.gender, users.user_name, users.email, COALESCE(COUNT( DISTINCT orders.id), 0) as total_order_times, COALESCE(SUM(orders.total), 0) as order_total, COALESCE(AVG(orders.total), 0) as avg_total').where(orders: {deleted_at: nil}).group(:id).order('order_total DESC')
  end

  private

  def search_params
    params.require(:user_search_term).permit(:ship_phone, :user_name, :email)
  end
end