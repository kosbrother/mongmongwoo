class Api::V3::UsersController < ApiController
  def create
    user = User.find_or_initialize_by(uid: params[:uid])
    user.email = params[:email] ||= SecureRandom.base64(20)
    user.user_name = params[:user_name]
    user.real_name = params[:real_name]
    user.gender = params[:gender]
    user.phone = params[:phone]
    user.address = params[:address]
    if user.save
      render json: "Successfully Create"
    else
      Rails.logger.error("error: #{user.errors.messages}")
      render json: "Error: #{user.errors.messages}", status: 400
    end
  end
end