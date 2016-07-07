class Api::V3::UsersController < ApiController
  def create
    user = User.find_or_initialize_by(email: params[:email])
    user.uid = params[:uid]
    user.password = User::FAKE_PASSWORD if  user.password_digest.nil?
    user.user_name = params[:user_name]
    user.gender = params[:gender]
    if user.save
      render status: 200, json: {data: "success"}
    else
      Rails.logger.error("error: #{user.errors.messages}")
      render status: 400, json: {error: {message: user.errors.messages.to_s}}
    end
  end
end
