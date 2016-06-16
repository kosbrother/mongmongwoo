class Api::V3::UsersController < ApiController
  def create
    user = User.find_or_initialize_by(uid: params[:uid])
    user.email = params[:email]
    user.user_name = params[:user_name]
    user.gender = params[:gender]
    if user.save
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error("error: #{user.errors.messages}")
      render status: 400, json: {error: {message: user.errors.messages}}
    end
  end
end
